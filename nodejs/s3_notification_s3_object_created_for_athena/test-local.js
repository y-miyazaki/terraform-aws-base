import { readFile } from "node:fs/promises";
import * as path from "path";
import { fileURLToPath } from "url";
import fs from "fs";

// Setting up the test event path (trying multiple locations)
const __dirname = path.dirname(fileURLToPath(import.meta.url));
let TEST_EVENT_PATH = path.join(__dirname, "test", "valid-sample-event.json");

// Try alternative path if the file doesn't exist
if (!fs.existsSync(TEST_EVENT_PATH)) {
    console.log(`File not found: ${TEST_EVENT_PATH}`);
    TEST_EVENT_PATH = "./test/valid-sample-event.json";
    console.log(`Trying alternative path: ${TEST_EVENT_PATH}`);
}

// Setting environment variables
process.env.TARGET_KEY_PREFIX = "partitioned/";

async function runLocalTest() {
    try {
        console.log(
            "Starting local test for S3 notification event processing...",
        );

        // Loading test event
        console.log(`Loading test file: ${TEST_EVENT_PATH}`);

        // Checking if the file exists
        if (!fs.existsSync(TEST_EVENT_PATH)) {
            console.error(`Error: Test file not found: ${TEST_EVENT_PATH}`);
            console.log("Checking directory contents:");
            console.log("Current directory:", process.cwd());
            console.log("./test directory contents:");
            try {
                console.log(fs.readdirSync("./test"));
            } catch (e) {
                console.log("test directory not found");
            }
            return;
        }

        const eventData = await readFile(TEST_EVENT_PATH, "utf8");
        const event = JSON.parse(eventData);

        console.log("Event data loaded");
        console.log(`Number of records to process: ${event.Records.length}`);

        // Importing test Lambda implementation
        console.log("Importing test Lambda function...");
        const { handler } = await import("./test/index-test.mjs");

        // Executing Lambda function
        console.log("Executing Lambda function...");
        await handler(event);

        console.log("Test execution completed");
    } catch (error) {
        console.error("Error occurred during test execution:", error);
        console.error(error.stack);
    }
}

// Run the test
runLocalTest();
