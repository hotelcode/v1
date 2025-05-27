# path: README.md
# Hotel AI Reception 🏨

[![Python Version](https://img.shields.io/badge/python-3.12.3-blue.svg)](https://python.org)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Code Coverage](https://img.shields.io/codecov/c/github/your-org/hotel-ai-reception)](https://codecov.io/gh/your-org/hotel-ai-reception)
[![Semantic Version](https://img.shields.io/badge/semver-2.0.0-blue)](https://semver.org/)

AI-powered hotel reception management system with voice assistant, automated booking, and intelligent guest services.

## 🚀 Features

- **AI Chat Assistant** - Multi-language support (RU/EN/KK) with voice capabilities
- **Booking Management** - Real-time room availability and reservation system
- **Payment Processing** - Multiple payment methods with automatic reconciliation
- **Staff Management** - Role-based access for managers, housekeepers, and guests
- **Telegram Integration** - Bot commands for staff operations
- **Monitoring & Observability** - Prometheus, Grafana, OpenTelemetry
- **Automated Tasks** - Check-in/out reminders, housekeeping alerts, daily reports

## 📋 Requirements

- Docker & Docker Compose
- Python 3.12.3
- PostgreSQL 15
- Redis 7
- Make

## 🛠️ Installation

1. Clone the repository:
```bash
git clone https://github.com/your-org/hotel-ai-reception.git
cd hotel-ai-reception
```

2. Copy environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration
```

3. Install dependencies:
```bash
make install
```

4. Start services:
```bash
make docker-up
```

5. Run migrations:
```bash
make migrate
```

## 🧪 Testing

Run tests with coverage:
```bash
make test
```

Run only light tests (no external dependencies):
```bash
make test-light
```

## 🚀 Development

Start development server:
```bash
make dev
```

Format code:
```bash
make fmt
```

Run linting:
```bash
make lint
```

Type checking:
```bash
make type-check
```

## 📊 SLA Metrics

Check performance metrics:
```bash
make sla-check
```

| Metric | Target | Measurement |
|--------|--------|-------------|
| `/healthz` response | 2xx with trace-id | CI + monitoring |
| `/chat` P95 latency | ≤ 400ms (1 connection) | Local + CI |
| Availability | 99.9% rolling 24h | External monitoring |
| Test coverage | ≥ 70% | CI pipeline |

## 🔧 API Endpoints

### Health Checks
- `GET /healthz` - Service health status
- `GET /readyz` - Readiness probe
- `GET /livez` - Liveness probe

### WebSocket
- `WS /chat` - Real-time chat with AI assistant

### REST API
- `GET /api/v1/rooms` - List available rooms
- `POST /api/v1/bookings` - Create booking
- `GET /api/v1/bookings/{id}` - Get booking details
- `POST /api/v1/payments` - Process payment

## 📱 Telegram Bot Commands

### Guest Commands
- `/bookings` - View your bookings
- `/help` - List available commands

### Housekeeper Commands
- `/cleaned <room>` - Mark room as cleaned
- `/cleaning` - List rooms needing cleaning

### Manager Commands
- `/set_price <room> <price>` - Update room price
- `/refund <booking> <amount>` - Process refund
- `/report` - Generate daily report
- `/overbooking` - Check overbooking status

## 🏗️ Architecture

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Caddy     │────▶│  FastAPI    │────▶│ PostgreSQL  │
│   Proxy     │     │   Monolith  │     │     DB      │
└─────────────┘     └─────────────┘     └─────────────┘
                           │
                    ┌──────┴──────┐
                    │             │
              ┌─────▼─────┐ ┌────▼────┐
              │   Redis   │ │ AI Stubs │
              │   Cache   │ │ Services │
              └───────────┘ └──────────┘
```

## 🔐 Security

- JWT-based authentication
- Role-based access control (RBAC)
- Rate limiting on API endpoints
- Secure password hashing (bcrypt)
- SQL injection protection
- XSS prevention headers

## 📈 Monitoring

Access monitoring dashboards:
```bash
make monitoring
```

- **Grafana**: http://localhost:3000
- **Prometheus**: http://localhost:9090

## 🚢 Deployment

Build and push Docker images:
```bash
make deploy
```

The CI/CD pipeline automatically:
1. Runs linting and type checking
2. Executes test suite
3. Performs security scanning
4. Builds Docker images
5. Pushes to registry
6. Deploys to production

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes using [Conventional Commits](https://www.conventionalcommits.org/)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- AI Development Team
- DevOps Engineers
- QA Engineers
- Product Managers

## 📞 Support

For support, email support@hotel-ai.com or join our Slack channel.

---

Built with ❤️ by Hotel AI Team