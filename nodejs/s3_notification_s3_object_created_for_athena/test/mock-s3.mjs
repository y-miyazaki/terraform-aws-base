import { CopyObjectCommand, DeleteObjectCommand } from "@aws-sdk/client-s3";

export function createMockS3() {
    const operations = [];

    return {
        operations,
        send: async (command) => {
            if (command instanceof CopyObjectCommand) {
                operations.push({
                    type: "copy",
                    copySource: command.input.CopySource,
                    bucket: command.input.Bucket,
                    key: command.input.Key,
                });
                return {};
            }

            if (command instanceof DeleteObjectCommand) {
                operations.push({
                    type: "delete",
                    bucket: command.input.Bucket,
                    key: command.input.Key,
                });
                return {};
            }

            throw new Error(`Unsupported command: ${command.constructor.name}`);
        },
    };
}
