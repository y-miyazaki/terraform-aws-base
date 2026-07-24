import { S3, CopyObjectCommand, DeleteObjectCommand } from "@aws-sdk/client-s3";

const defaultS3 = new S3({ apiVersion: "2006-03-01" });

// regex for filenames by Amazon CloudFront access logs. Groups:
// - 1. year
// - 2. month
// - 3. day
// - 4. hour
const datePattern = "[^\\d](\\d{4})-(\\d{2})-(\\d{2})-(\\d{2})[^\\d]";
const filenamePattern = "[^/]+$";

export function parseAccessLogKey(sourceKey) {
    const sourceRegex = new RegExp(datePattern, "g");
    const match = sourceRegex.exec(sourceKey);
    if (!match) {
        return null;
    }

    const [, year, month, day, hour] = match;
    const filenameRegex = new RegExp(filenamePattern, "g");
    const filename = filenameRegex.exec(sourceKey)[0];

    return { year, month, day, hour, filename };
}

export function buildTargetKey(sourceKey, targetKeyPrefix) {
    const parsed = parseAccessLogKey(sourceKey);
    if (!parsed) {
        return null;
    }

    const { year, month, day, filename } = parsed;
    return `${targetKeyPrefix}${year}/${month}/${day}/${filename}`;
}

export async function processS3Record(record, { s3, targetKeyPrefix }) {
    const bucket = record.s3.bucket.name;
    const sourceKey = record.s3.object.key;
    const targetKey = buildTargetKey(sourceKey, targetKeyPrefix);

    if (!targetKey) {
        console.log(
            `Object key ${sourceKey} does not look like an access log file, so it will not be moved.`
        );
        return;
    }

    const copyObjectCommand = new CopyObjectCommand({
        CopySource: `/${bucket}/${sourceKey}`,
        Bucket: bucket,
        Key: targetKey,
    });

    try {
        await s3.send(copyObjectCommand);
    } catch (err) {
        console.error(`Error copying ${bucket}/${sourceKey}: ${err}`);
        return;
    }

    const deleteObjectCommand = new DeleteObjectCommand({
        Bucket: bucket,
        Key: sourceKey,
    });

    try {
        await s3.send(deleteObjectCommand);
    } catch (err) {
        console.error(`Error deleting ${sourceKey}: ${err}`);
    }
}

export function createHandler({
    s3 = defaultS3,
    targetKeyPrefix = process.env.TARGET_KEY_PREFIX,
} = {}) {
    return async (event) => {
        const moves = event.Records.map((record) =>
            processS3Record(record, { s3, targetKeyPrefix })
        );
        await Promise.all(moves);
    };
}

export const handler = createHandler();
