import mongoose from "mongoose";

let isConnected = false; // กัน connect ซ้ำ

export const connectMongoDB = async () => {
  if (isConnected) {
    console.log("🔄 Already connected to MongoDB");
    return;
  }

  try {
    const conn = await mongoose.connect(process.env.MONGODB_URI, {
      dbName: "test", // ใส่ถ้าใน URI ไม่มี dbname
    });

    isConnected = conn.connections[0].readyState === 1;
    console.log("✅ Connected to MongoDB:", conn.connection.host);
  } catch (error) {
    console.error("❌ MongoDB connection error:", error);
    throw new Error("Cannot connect to MongoDB");
  }
};
