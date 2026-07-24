import * as zlib from "node:zlib";
import * as fs from "node:fs/promises";

// CloudWatch Logsの形式のサンプルデータ
const sampleData = {
    messageType: "DATA_MESSAGE",
    owner: "123456789012",
    logGroup: "/aws/lambda/my-lambda-function",
    logStream: "2023/05/08/[$LATEST]abc123def456",
    subscriptionFilters: ["my-subscription-filter"],
    logEvents: [
        {
            id: "01234567890123456789012345678901234567890123456789012345",
            timestamp: 1683532800000,
            message:
                "2023-05-08T10:00:00.000Z\tINFO\tLambda function started processing",
        },
        {
            id: "01234567890123456789012345678901234567890123456789012346",
            timestamp: 1683532800100,
            message:
                "2023-05-08T10:00:00.100Z\tINFO\tProcessed 100 records successfully",
        },
        {
            id: "01234567890123456789012345678901234567890123456789012347",
            timestamp: 1683532800200,
            message:
                "2023-05-08T10:00:00.200Z\tERROR\tFailed to process record #42: Invalid input format",
        },
    ],
};

// データをGZIP圧縮してBase64エンコード
function compressAndEncode(data) {
    const jsonString = JSON.stringify(data);
    const buffer = Buffer.from(jsonString, "utf-8");
    const compressed = zlib.gzipSync(buffer);
    return compressed.toString("base64");
}

// Firehoseイベントを作成
async function createFirehoseEvent() {
    const base64Data = compressAndEncode(sampleData);

    const firehoseEvent = {
        deliveryStreamArn:
            "arn:aws:firehose:us-east-1:123456789012:deliverystream/my-delivery-stream",
        records: [
            {
                recordId:
                    "49615338669541255871590765702795576036079249399008288770",
                data: base64Data,
            },
            {
                recordId:
                    "49615338669541255871590765702796785962698864124167954434",
                data: base64Data,
            },
        ],
    };

    await fs.writeFile(
        "./test/valid-sample-event.json",
        JSON.stringify(firehoseEvent, null, 2),
    );
    console.log("テストデータを作成しました: test/valid-sample-event.json");
}

// Kinesisイベントを作成
async function createKinesisEvent() {
    const base64Data = compressAndEncode(sampleData);

    const kinesisEvent = {
        sourceKinesisStreamArn:
            "arn:aws:kinesis:us-east-1:123456789012:stream/my-kinesis-stream",
        records: [
            {
                recordId:
                    "49615338669541255871590765702795576036079249399008288770",
                data: base64Data,
                kinesisRecordMetadata: {
                    partitionKey: "test-partition-key",
                    sequenceNumber:
                        "49615338669541255871590765702795576036079249399008288770",
                    subsequenceNumber: 0,
                    shardId: "shardId-000000000000",
                    approximateArrivalTimestamp: 1510109208016,
                },
            },
            {
                recordId:
                    "49615338669541255871590765702796785962698864124167954434",
                data: base64Data,
                kinesisRecordMetadata: {
                    partitionKey: "test-partition-key",
                    sequenceNumber:
                        "49615338669541255871590765702796785962698864124167954434",
                    subsequenceNumber: 0,
                    shardId: "shardId-000000000000",
                    approximateArrivalTimestamp: 1510109208017,
                },
            },
        ],
    };

    await fs.writeFile(
        "./test/valid-sample-kinesis-event.json",
        JSON.stringify(kinesisEvent, null, 2),
    );
    console.log(
        "テストデータを作成しました: test/valid-sample-kinesis-event.json",
    );
}

// テストデータを作成
async function main() {
    await createFirehoseEvent();
    await createKinesisEvent();
}

main().catch(console.error);
