# CustomerClient

Angular-klient (standalone, signals) för `CustomersApi`. Kväll 4 i Azure-kursen.

## Kommandon
```powershell
npm ci
npm start                          # ng serve, http://localhost:4200
npm test -- --watch=false          # Vitest + jsdom, ingen webbläsare behövs
npm run build                      # utdata i dist\CustomerClient\browser
```

## Konfiguration
`public/config.json` läses vid start (runtime). Deploy-skriptet skriver över `apiBaseUrl`
med det publicerade API:ts adress, så bygget är detsamma i alla miljöer.

## API (CustomersApi)
- `GET /customers`, `POST /customers`, `DELETE /customers/{guid}`
- `GET /healthz`, `GET /db/whoami`
- `Customer`: `{ id: guid, name, email?, phone?, city?, createdAt, updatedAt? }`

## Static Web Apps
`public/staticwebapp.config.json` ger fallback till `index.html` så att djuplänkar (F5 på `/status`) fungerar.
CORS sätts på API:t (App Service) med SWA:ns hostname i `allowedOrigins`.
