import { readFile } from 'node:fs/promises';
import { handler } from './index.mjs';

// Test event file path (using newly generated valid test data)
const TEST_EVENT_PATH = './test/valid-sample-event.json';

async function runLocalTest() {
  try {
    console.log('Starting local test of Lambda function...');

    // Load test event
    const eventData = await readFile(TEST_EVENT_PATH, 'utf8');
    const event = JSON.parse(eventData);

    console.log('Event data loaded');

    // Execute Lambda function
    console.log('Executing Lambda function...');
    const response = await handler(event);

    // Output results
    console.log('Lambda function execution results:');
    console.log(JSON.stringify(response, null, 2));

    // Count successful records
    const successCount = response.records.filter(record => record.result === 'Ok').length;
    console.log(`${successCount} out of ${response.records.length} records processed successfully`);

  } catch (error) {
    console.error('Error occurred during test execution:', error);
  }
}

// Run test
runLocalTest();
