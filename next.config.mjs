/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    remotePatterns: [
      { protocol: "https", hostname: "**.fbcdn.net" },
      { protocol: "https", hostname: "travel.mthai.com" },
      { protocol: "https", hostname: "images.pexels.com" },
    ],
  },
};



export default nextConfig;
