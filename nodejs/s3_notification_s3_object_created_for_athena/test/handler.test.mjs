import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { describe, it } from "node:test";

import {
    buildTargetKey,
    createHandler,
    parseAccessLogKey,
} from "../index.mjs";
import { createMockS3 } from "./mock-s3.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

describe("parseAccessLogKey", () => {
    it("extracts date parts and filename from CloudFront access log keys", () => {
        const parsed = parseAccessLogKey(
            "logs/E1ABCDEFGHI2J3.2023-05-08-12.a1b2c3d4.gz"
        );

        assert.deepEqual(parsed, {
            year: "2023",
            month: "05",
            day: "08",
            hour: "12",
            filename: "E1ABCDEFGHI2J3.2023-05-08-12.a1b2c3d4.gz",
        });
    });

    it("returns null for keys that do not match the access log pattern", () => {
        assert.equal(parseAccessLogKey("logs/invalid-key.txt"), null);
    });
});

describe("buildTargetKey", () => {
    it("builds a partitioned target key", () => {
        const targetKey = buildTargetKey(
            "logs/E1ABCDEFGHI2J3.2023-05-08-12.a1b2c3d4.gz",
            "partitioned/"
        );

        assert.equal(
            targetKey,
            "partitioned/2023/05/08/E1ABCDEFGHI2J3.2023-05-08-12.a1b2c3d4.gz"
        );
    });
});

describe("createHandler", () => {
    it("copies and deletes each valid S3 notification record", async () => {
        const mockS3 = createMockS3();
        const handler = createHandler({
            s3: mockS3,
            targetKeyPrefix: "partitioned/",
        });
        const event = JSON.parse(
            await readFile(path.join(__dirname, "valid-sample-event.json"), "utf8")
        );

        await handler(event);

        assert.equal(mockS3.operations.length, 4);
        assert.deepEqual(
            mockS3.operations.filter((operation) => operation.type === "copy"),
            [
                {
                    type: "copy",
                    copySource:
                        "/example-bucket/logs/E1ABCDEFGHI2J3.2023-05-08-12.a1b2c3d4.gz",
                    bucket: "example-bucket",
                    key: "partitioned/2023/05/08/E1ABCDEFGHI2J3.2023-05-08-12.a1b2c3d4.gz",
                },
                {
                    type: "copy",
                    copySource:
                        "/example-bucket/logs/E1ABCDEFGHI2J3.2023-05-08-14.x9y8z7w6.gz",
                    bucket: "example-bucket",
                    key: "partitioned/2023/05/08/E1ABCDEFGHI2J3.2023-05-08-14.x9y8z7w6.gz",
                },
            ]
        );
        assert.deepEqual(
            mockS3.operations.filter((operation) => operation.type === "delete"),
            [
                {
                    type: "delete",
                    bucket: "example-bucket",
                    key: "logs/E1ABCDEFGHI2J3.2023-05-08-12.a1b2c3d4.gz",
                },
                {
                    type: "delete",
                    bucket: "example-bucket",
                    key: "logs/E1ABCDEFGHI2J3.2023-05-08-14.x9y8z7w6.gz",
                },
            ]
        );
    });

    it("skips records that do not match the access log key format", async () => {
        const mockS3 = createMockS3();
        const handler = createHandler({
            s3: mockS3,
            targetKeyPrefix: "partitioned/",
        });

        await handler({
            Records: [
                {
                    s3: {
                        bucket: { name: "example-bucket" },
                        object: { key: "logs/not-an-access-log.txt" },
                    },
                },
            ],
        });

        assert.equal(mockS3.operations.length, 0);
    });
});
