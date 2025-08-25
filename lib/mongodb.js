// import mongoose, { mongo } from "mongoose";
//
// export const connectMongoDB = async () => {
//     try {
//
//         await mongoose.connect(process.env.MONGODB_URI);
//         console.log("Connected to mongodb");
//
//     } catch(error) {
//         console.log("Error connecting to mongodb: ", error)
//     }
// }
import mongoose from "mongoose";

let isConnected = false; // เพื่อกันไม่ให้ connect ซ้ำ

export const connectMongoDB = async () => {
    if (isConnected) {
        console.log("🔄 Already connected to MongoDB");
        return;
    }

    try {
        const conn = await mongoose.connect(process.env.MONGODB_URI, {
            dbName: "test",   // ใส่ตรง ๆ ให้ตรงกับ Atlas
            useNewUrlParser: true,
            useUnifiedTopology: true,
        });

        isConnected = conn.connections[0].readyState === 1;
        console.log("✅ Connected to MongoDB:", conn.connection.host);
    } catch (error) {
        console.error("❌ MongoDB connection error:", error);
        throw new Error("Cannot connect to MongoDB");
    }
};