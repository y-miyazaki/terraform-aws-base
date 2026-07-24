import { readFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { createHandler } from "./index.mjs";
import { createMockS3 } from "./test/mock-s3.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const TEST_EVENT_PATH = path.join(__dirname, "test", "valid-sample-event.json");

process.env.TARGET_KEY_PREFIX = "partitioned/";

async function runLocalTest() {
    console.log("Starting local test for S3 notification event processing...");

    const eventData = await readFile(TEST_EVENT_PATH, "utf8");
    const event = JSON.parse(eventData);
    const mockS3 = createMockS3();
    const handler = createHandler({
        s3: mockS3,
        targetKeyPrefix: process.env.TARGET_KEY_PREFIX,
    });

    console.log(`Number of records to process: ${event.Records.length}`);
    await handler(event);

    if (mockS3.operations.length !== event.Records.length * 2) {
        throw new Error(
            `Expected ${event.Records.length * 2} S3 operations, got ${mockS3.operations.length}`
        );
    }

    console.log("Test execution completed");
}

runLocalTest().catch((error) => {
    console.error("Error occurred during test execution:", error);
    process.exitCode = 1;
});
