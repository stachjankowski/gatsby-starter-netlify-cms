# Endpoint Danych o Inflacji - Szybki Start

## 🚀 Co zostało dodane

1. **Nowy endpoint API**: `/.netlify/functions/inflation`
2. **Baza danych PostgreSQL** z tabelami walut i danych inflacyjnych
3. **Kompletna dokumentacja** API z przykładami użycia

## 📋 Wymagane kroki do uruchomienia

### 1. Instalacja zależności
```bash
npm install
```

### 2. Konfiguracja bazy danych
1. Utwórz bazę danych PostgreSQL
2. Wykonaj skrypt: `database/schema.sql`
3. Ustaw zmienną środowiskową `DATABASE_URL`

### 3. Zmienne środowiskowe
Dodaj w Netlify lub lokalnie w `.env`:
```bash
DATABASE_URL=postgresql://username:password@host:port/database_name
NODE_ENV=production
```

## 🎯 Użycie endpointa

### Podstawowe zapytanie
```bash
curl "https://your-site.netlify.app/.netlify/functions/inflation?currency_code=PLN"
```

### Przykład odpowiedzi
```json
{
  "currency_code": "PLN",
  "country_code": "PL", 
  "country_name": "Polska",
  "data_period": {
    "from": { "year": 2020, "month": 1 },
    "to": { "year": 2023, "month": 12 },
    "total_months": 48
  },
  "statistics": {
    "mean": 8.2458,
    "standard_deviation": 5.2341,
    "min": 2.4,
    "max": 18.4
  }
}
```

## 📚 Dostępne waluty

✅ **PLN** - Polski złoty  
✅ **USD** - Dolar amerykański  
✅ **EUR** - Euro  
✅ **GBP** - Funt brytyjski  
✅ **JPY** - Jen japoński  
✅ **CHF** - Frank szwajcarski  
✅ **CAD** - Dolar kanadyjski  
✅ **AUD** - Dolar australijski  

## 📖 Pełna dokumentacja

- **API Documentation**: `docs/INFLATION_API.md`
- **Database Setup**: `docs/DATABASE_SETUP.md`

## 🔧 Struktura plików

```
├── lambda/
│   └── inflation.js          # Główny endpoint
├── database/
│   └── schema.sql            # Schemat bazy danych
├── docs/
│   ├── INFLATION_API.md      # Dokumentacja API
│   └── DATABASE_SETUP.md     # Instrukcje bazy danych
└── package.json              # Zaktualizowane zależności
```

## 🚀 Testowanie lokalnie

```bash
# Zainstaluj Netlify CLI
npm install -g netlify-cli

# Uruchom funkcje lokalnie
netlify dev

# Testuj endpoint
curl "http://localhost:8888/.netlify/functions/inflation?currency_code=PLN"
```

## ⚡ Szybkie hosting bazy danych

### ElephantSQL (Bezpłatny)
1. Idź na https://elephantsql.com
2. Utwórz konto i nową instancję
3. Skopiuj URL połączenia
4. Wykonaj skrypt schema.sql w konsoli

### Supabase (Nowoczesny)
1. Idź na https://supabase.com
2. Utwórz nowy projekt
3. Użyj SQL Editor do wykonania schema.sql
4. Skopiuj connection string

## 📊 Przykłady zastosowań

### JavaScript/TypeScript
```javascript
const inflationData = await fetch('/.netlify/functions/inflation?currency_code=PLN')
  .then(res => res.json());

console.log(`Średnia inflacja: ${inflationData.statistics.mean}%`);
```

### React Hook
```javascript
const useInflationData = (currency) => {
  const [data, setData] = useState(null);
  
  useEffect(() => {
    fetch(`/.netlify/functions/inflation?currency_code=${currency}`)
      .then(res => res.json())
      .then(setData);
  }, [currency]);
  
  return data;
};
```

## 🛠️ Rozszerzenia

Endpoint można łatwo rozszerzyć o:
- Filtrowanie po dacie
- Porównanie wielu walut
- Prognozy inflacji
- Dane historyczne w różnych formatach
- API do dodawania nowych danych

## 💡 Pomoc

Jeśli masz problemy:
1. Sprawdź logi Netlify Functions
2. Zweryfikuj połączenie z bazą danych
3. Upewnij się, że zmienne środowiskowe są poprawnie ustawione
4. Sprawdź dokumentację w katalogu `docs/`