import { connectMongoDB } from "@/lib/mongodb";
import Post from "@/models/post";

export default async function handler(req, res) {
    try {
        await connectMongoDB();  // ✅ ต้องเรียกก่อน
        const posts = await Post.find();
        res.status(200).json(posts);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Database error" });
    }
}