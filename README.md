# Beatlix

A shared space for group activities - chat, screen share, listen to music, or just hang out together. Audio, video, and screen sharing are peer-to-peer via WebRTC. The server only stores the minimum needed for identity: user accounts and group IDs.

## Project Structure

```
beatlix/
├── homepage/        # Main web app (Vue + Vite)
├── packages/        # Shared packages
└── plans/           # Research and planning docs
```

## Development

```bash
pnpm install

# Run all packages in dev mode
pnpm dev

# Build all packages
pnpm build

# Lint all packages
pnpm lint
```

## Homepage only

```bash
pnpm --filter @beatlix/homepage run dev
pnpm --filter @beatlix/homepage run build
```
