const pool = require("../db");
const fs = require("fs");

async function setupDatabase() {
  const schema = fs.readFileSync("./database/schema.sql", "utf8");
  const connection = await pool.getConnection();
  try {
    await connection.query(schema);
    console.log("✅ Database & Tables Created");
  } catch (error) {
    console.error("❌ Error setting up database:", error);
  } finally {
    connection.release();
    process.exit();
  }
}

setupDatabase();
