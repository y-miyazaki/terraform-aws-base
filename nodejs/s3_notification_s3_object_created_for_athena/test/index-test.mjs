// Implementation of S3 client for testing (mock)
const mockS3 = {
    send: async (command) => {
        // Branch processing based on command type
        if (command instanceof CopyObjectCommand) {
            console.log(
                `[Mock] S3 copy operation: ${command.input.CopySource} -> ${command.input.Bucket}/${command.input.Key}`,
            );
            return {};
        } else if (command instanceof DeleteObjectCommand) {
            console.log(
                `[Mock] S3 delete operation: ${command.input.Bucket}/${command.input.Key}`,
            );
            return {};
        }
        throw new Error(`Unsupported command: ${command.constructor.name}`);
    },
};

// Mock command classes
class CopyObjectCommand {
    constructor(input) {
        this.input = input;
    }
}

class DeleteObjectCommand {
    constructor(input) {
        this.input = input;
    }
}

// prefix to copy partitioned data to w/o leading but w/ trailing slash
const targetKeyPrefix = process.env.TARGET_KEY_PREFIX || "partitioned/";

// regex for filenames by Amazon CloudFront access logs. Groups:
// - 1.	year
// - 2.	month
// - 3.	day
// - 4.	hour
const datePattern = "[^\\d](\\d{4})-(\\d{2})-(\\d{2})-(\\d{2})[^\\d]";
const filenamePattern = "[^/]+$";

export const handler = async (event) => {
    console.log("Starting S3 notification event processing...");

    const moves = event.Records.map(async (record) => {
        const bucket = record.s3.bucket.name;
        const sourceKey = record.s3.object.key;

        console.log(`Processing started: ${bucket}/${sourceKey}`);

        const sourceRegex = new RegExp(datePattern, "g");
        const match = sourceRegex.exec(sourceKey);
        if (!match) {
            console.log(
                `Object key ${sourceKey} does not match access log file format, will not be moved.`,
            );
            return;
        }
        const [, year, month, day, hour] = match;

        const filenameRegex = new RegExp(filenamePattern, "g");
        const filename = filenameRegex.exec(sourceKey)[0];

        const targetKey = `${targetKeyPrefix}${year}/${month}/${day}/${filename}`;

        console.log(`Executing copy: ${sourceKey} to ${targetKey}`);

        const copyObjectCommand = new CopyObjectCommand({
            CopySource: `/${bucket}/${sourceKey}`,
            Bucket: bucket,
            Key: targetKey,
        });

        try {
            await mockS3.send(copyObjectCommand);
            console.log(
                `Copy successful: ${bucket}/${sourceKey} to ${bucket}/${targetKey}`,
            );
        } catch (err) {
            console.error(
                `Error during copy operation ${bucket}/${sourceKey}: ${err}`,
            );
            return;
        }

        const deleteObjectCommand = new DeleteObjectCommand({
            Bucket: bucket,
            Key: sourceKey,
        });

        try {
            await mockS3.send(deleteObjectCommand);
            console.log(`Delete successful: ${sourceKey}`);
        } catch (err) {
            console.error(`Error during delete operation ${sourceKey}: ${err}`);
        }
    });
    await Promise.all(moves);
    console.log("All file processing completed");
};
