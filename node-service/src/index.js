// node-service/src/index.js
import express from "express";
import { Pool } from "pg";
import { DynamoDBClient, ListTablesCommand } from "@aws-sdk/client-dynamodb";

const app = express();
app.use(express.json());

// ── Postgres ──────────────────────────────────────────────────────────────────
const pg = new Pool({ connectionString: process.env.DATABASE_URL });

// ── DynamoDB ──────────────────────────────────────────────────────────────────
const dynamo = new DynamoDBClient({
  endpoint: process.env.DYNAMODB_ENDPOINT,
  region: process.env.AWS_REGION ?? "us-east-1",
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID ?? "local",
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY ?? "local",
  },
});

// ── Routes ────────────────────────────────────────────────────────────────────
app.get("/health", async (_req, res) => {
  try {
    await pg.query("SELECT 1");
    await dynamo.send(new ListTablesCommand({}));
    res.json({ status: "ok", service: "node-service" });
  } catch (err) {
    res.status(503).json({ status: "error", message: err.message });
  }
});

app.get("/users", async (_req, res) => {
  const { rows } = await pg.query("SELECT * FROM users ORDER BY created_at DESC LIMIT 50");
  res.json(rows);
});

// ── Start ─────────────────────────────────────────────────────────────────────
const PORT = process.env.PORT ?? 3001;
app.listen(PORT, () => console.log(`node-service listening on :${PORT}`));
