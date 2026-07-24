import { readFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { handler } from "./index.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const TEST_EVENT_PATH = path.join(__dirname, "test", "valid-sample-event.json");

async function runLocalTest() {
    console.log("Starting local test of Lambda function...");

    const eventData = await readFile(TEST_EVENT_PATH, "utf8");
    const event = JSON.parse(eventData);

    console.log("Event data loaded");
    console.log("Executing Lambda function...");

    const response = await handler(event);

    console.log("Lambda function execution results:");
    console.log(JSON.stringify(response, null, 2));

    const successCount = response.records.filter(
        (record) => record.result === "Ok"
    ).length;

    if (successCount !== response.records.length) {
        throw new Error(
            `Expected ${response.records.length} successful records, got ${successCount}`
        );
    }

    console.log(
        `${successCount} out of ${response.records.length} records processed successfully`
    );
}

runLocalTest().catch((error) => {
    console.error("Error occurred during test execution:", error);
    process.exitCode = 1;
});
