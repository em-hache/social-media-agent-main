/** @type {import('next').NextConfig} */
const nextConfig = {
  // Required for the minimal Docker image (stage 3 in Dockerfile)
  output: "standalone",

  // Rewrite API calls during SSR to internal Docker hostnames
  async rewrites() {
    return [
      {
        source: "/api/node/:path*",
        destination: `${process.env.NODE_API_URL ?? "http://node-service:3001"}/:path*`,
      },
      {
        source: "/api/fastapi/:path*",
        destination: `${process.env.FASTAPI_URL ?? "http://fastapi-service:8080"}/:path*`,
      },
    ];
  },
};

module.exports = nextConfig;
