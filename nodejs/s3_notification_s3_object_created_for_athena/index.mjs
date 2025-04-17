import { S3, CopyObjectCommand, DeleteObjectCommand } from "@aws-sdk/client-s3";
const s3 = new S3({ apiVersion: "2006-03-01" });

// prefix to copy partitioned data to w/o leading but w/ trailing slash
const targetKeyPrefix = process.env.TARGET_KEY_PREFIX;

// regex for filenames by Amazon CloudFront access logs. Groups:
// - 1.	year
// - 2.	month
// - 3.	day
// - 4.	hour
const datePattern = "[^\\d](\\d{4})-(\\d{2})-(\\d{2})-(\\d{2})[^\\d]";
const filenamePattern = "[^/]+$";

export const handler = async (event) => {
    const moves = event.Records.map(async (record) => {
        const bucket = record.s3.bucket.name;
        const sourceKey = record.s3.object.key;

        const sourceRegex = new RegExp(datePattern, "g");
        const match = sourceRegex.exec(sourceKey);
        if (!match) {
            console.log(
                `Object key ${sourceKey} does not look like an access log file, so it will not be moved.`
            );
            return;
        }
        const [, year, month, day, hour] = match;

        const filenameRegex = new RegExp(filenamePattern, "g");
        const filename = filenameRegex.exec(sourceKey)[0];

        const targetKey = `${targetKeyPrefix}${year}/${month}/${day}/${filename}`;

        // console.log(`Copying ${sourceKey} to ${targetKey}.`);

        const copyObjectCommand = new CopyObjectCommand({
            CopySource: `/${bucket}/${sourceKey}`,
            Bucket: bucket,
            Key: targetKey,
        });

        try {
            await s3.send(copyObjectCommand);
            // console.log(`Copied ${bucket}/${sourceKey} to ${bucket}/${targetKey}`);
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
            // console.log(`Deleted ${sourceKey}`);
        } catch (err) {
            console.error(`Error deleting ${sourceKey}: ${err}`);
        }
    });
    await Promise.all(moves);
};
