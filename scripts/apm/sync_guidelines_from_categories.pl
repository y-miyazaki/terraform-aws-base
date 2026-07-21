#!/usr/bin/env perl
use strict;
use warnings;
use File::Glob ':glob';

# Sync flow:
# 1) category-*.md: normalize rule title lines to "**ID (LEVEL): Title**"
# 2) common-checklist.md: regenerate mechanically from category headers + rules
# 3) instructions/*.instructions.md: replace Guidelines block with checklist content
#    (## in checklist -> ### under Guidelines)

my %map = (
  'agent-skills-review'   => '.apm/packages/common/.apm/instructions/agent-skills.instructions.md',
  'github-actions-review' => '.apm/packages/common/.apm/instructions/github-actions-workflow.instructions.md',
  'go-review'             => '.apm/packages/go/.apm/instructions/go.instructions.md',
  'instructions-review'   => '.apm/packages/common/.apm/instructions/instructions.instructions.md',
  'shell-script-review'   => '.apm/packages/shell-script/.apm/instructions/shell-script.instructions.md',
  'terraform-review'      => '.apm/packages/terraform/.apm/instructions/terraform.instructions.md',
);

my %code_mod_guidelines = (
  'agent-skills-review' => [
    '- Automate deterministic checks (existence, quantitative, file presence) in skill `scripts/`; keep judgment-based checks in the review skill workflow.',
  ],
  'github-actions-review' => [
    '- Keep `inputs`, `env`, `permissions`, and `with` keys alphabetically ordered (G-05).',
  ],
  'go-review' => [
    '- When adding or changing behavior, add or update *_test.go files in the same change.',
  ],
  'instructions-review' => [
    '- Keep applyTo precise to distributed rule paths; use stem-based companion cross-links (G-03, G-04, G-05).',
    '- Do not embed always-run lint/validate recipes or "hooks handle it" skip explanations in always-on instructions.',
    '- When instruction files are updated, re-evaluate instruction quality against this file\'s STRUCT/TEST rules.',
  ],
  'shell-script-review' => [
    '- When adding or changing shell scripts or sourced libraries, add or update matching Bats suites under test/bats/ (mirror the script path) in the same change; follow companion Bats rules (stem `bats`) for suite layout.',
  ],
  'terraform-review' => [
    '- Keep argument keys inside resource/module/data blocks alphabetically ordered (ORD-01).',
  ],
);

sub read_all {
  my ($f) = @_;
  open my $fh, '<', $f or die "open $f: $!\n";
  local $/;
  my $s = <$fh>;
  close $fh;
  return $s;
}

sub write_all {
  my ($f, $s) = @_;
  open my $fh, '>', $f or die "write $f: $!\n";
  print {$fh} $s;
  close $fh;
}

sub normalize_category_rule_line {
  my ($line, $lvl_ref) = @_;

  # Generic category style:
  # **ID: Title** or **ID (LEVEL): Title**
  if ($line =~ /^\*\*([A-Z][A-Z0-9]*-[0-9]+[a-z]?)(?: \((MUST|SHOULD|CAN)\))?:\s*(.*?)\*\*\s*$/) {
    my ($id, $cur, $title) = ($1, $2, $3);
    my $level = $lvl_ref->{$id} // $cur // 'SHOULD';
    return "**$id ($level): $title**\n";
  }

  # agent-skills category style:
  # ## ID: Title
  if ($line =~ /^## ([A-Z][A-Z0-9]*-[0-9]+[a-z]?):\s*(.+?)\s*$/) {
    my ($id, $title) = ($1, $2);
    my $level = $lvl_ref->{$id} // 'SHOULD';
    return "**$id ($level): $title**\n";
  }

  return $line;
}

sub normalize_section_header {
  my ($header) = @_;
  $header =~ s/^\s+//;
  $header =~ s/\s+$//;
  # Keep semantic label but drop ordering index like "6. " for H3 consistency.
  $header =~ s/^\d+\.\s+//;
  return $header;
}

for my $skill (sort keys %map) {
  my $instr = $map{$skill};
  # Extract package path from instruction file path (e.g., .apm/packages/common/.apm -> .apm/packages/common)
  # or determine ref_dir based on skill location
  my $ref_dir;
  if ($instr =~ m{^(.apm/packages/[^/]+)/\.apm/instructions/}) {
    $ref_dir = "$1/.apm/skills/$skill/references";
  } elsif ($instr =~ m{^\.apm/instructions/}) {
    $ref_dir = ".apm/skills/$skill/references";
  } else {
    next;
  }
  next unless -d $ref_dir;
  next unless -f $instr;

  my %level_by_id;
  my $instr_txt = read_all($instr);
  while ($instr_txt =~ /\*\*([A-Z][A-Z0-9]*-[0-9]+[a-z]?) \((MUST|SHOULD|CAN)\)\*\*:/g) {
    $level_by_id{$1} = $2;
  }

  my @category_files = grep { -f $_ } sort( bsd_glob("$ref_dir/category-*.md") );
  next if !@category_files;

  my @parsed_categories;

  # 1) normalize category files with levels
  for my $cf (@category_files) {
    open my $in, '<', $cf or die "open $cf: $!\n";
    my @out;
    while (my $line = <$in>) {
      push @out, normalize_category_rule_line($line, \%level_by_id);
    }
    close $in;
    write_all($cf, join('', @out));

    open my $pin, '<', $cf or die "open $cf: $!\n";
    my @sections;
    my $current;
    while (my $line = <$pin>) {
      chomp $line;

      if ($line =~ /^##\s+(.*)$/) {
        if (defined $current) {
          push @sections, $current;
        }
        $current = {
          header => $1,
          rules  => [],
        };
        next;
      }

      if ($line =~ /^\*\*([A-Z][A-Z0-9]*-[0-9]+[a-z]? \((?:MUST|SHOULD|CAN)\): .*?)\*\*$/) {
        next if !defined $current;
        push @{$current->{rules}}, {
          rule   => $1,
          checks => [],
        };
        next;
      }

      if ($line =~ /^Check:\s*(.+)$/) {
        next if !defined $current;
        next if !@{$current->{rules}};
        push @{$current->{rules}->[-1]->{checks}}, $1;
        next;
      }
    }
    close $pin;
    if (defined $current) {
      push @sections, $current;
    }
    push @parsed_categories, \@sections;
  }

  # 2) regenerate common-checklist.md
  my $checklist = "$ref_dir/common-checklist.md";
  next unless -f $checklist;

  my ($title) = split /\n/, read_all($checklist);
  my @out = ($title, '');

  for my $sections_ref (@parsed_categories) {
    for my $section (@{$sections_ref}) {
      next if !@{$section->{rules}};
      push @out, '' if @out && $out[-1] ne '';
      push @out, "## " . normalize_section_header($section->{header});
      for my $entry (@{$section->{rules}}) {
        push @out, "- " . $entry->{rule};
      }
    }
  }

  # compact blank lines
  my @normalized;
  my $prev_blank = 0;
  for my $l (@out) {
    if ($l eq '') {
      next if $prev_blank;
      $prev_blank = 1;
      push @normalized, $l;
    } else {
      $prev_blank = 0;
      push @normalized, $l;
    }
  }
  push @normalized, '' if @normalized && $normalized[-1] ne '';
  write_all($checklist, join("\n", @normalized));

  # 3) replace Guidelines in instruction
  #    Include both rule bullets and Check lines from category files.
  my @guideline_lines;
  for my $sections_ref (@parsed_categories) {
    for my $section (@{$sections_ref}) {
      next if !@{$section->{rules}};
      push @guideline_lines, '' if @guideline_lines && $guideline_lines[-1] ne '';
      push @guideline_lines, "### " . normalize_section_header($section->{header});
      for my $entry (@{$section->{rules}}) {
        push @guideline_lines, "- " . $entry->{rule};
        for my $check (@{$entry->{checks}}) {
          push @guideline_lines, "  - Check: " . $check;
        }
      }
    }
  }

  my $guideline_block = join("\n", @guideline_lines);
  $guideline_block =~ s/^\n+//;

  my $cmg_lines_ref = $code_mod_guidelines{$skill} // [];
  if (@{$cmg_lines_ref}) {
    $guideline_block .= "\n" if $guideline_block !~ /\n\z/;
    $guideline_block .= "\n### Code Modification Guidelines\n\n";
    $guideline_block .= join("\n", @{$cmg_lines_ref}) . "\n";
  }

  $guideline_block .= "\n";

  my $txt = read_all($instr);
  if ($txt =~ /\n## Guidelines\n.*?\n## Testing and Validation\n/s) {
    $txt =~ s/\n## Guidelines\n.*?\n## Testing and Validation\n/\n## Guidelines\n\n$guideline_block\n## Testing and Validation\n/s;
    write_all($instr, $txt);
  }
}

print "sync completed\n";
