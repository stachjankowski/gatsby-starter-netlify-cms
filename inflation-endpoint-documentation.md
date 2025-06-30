# Endpoint Inflacji - Dokumentacja

## Opis
Endpoint `/inflation` zwraca dane o inflacji dla zadanej waluty w projekcie kalkulatoremerytalny-backend.

## URL Endpoint
```
GET /.netlify/functions/inflation
```

## Parametry zapytania

| Parametr | Typ | Wymagany | Opis |
|----------|-----|----------|------|
| `currency` lub `currencyCode` | string | Tak | Kod waluty (np. USD, EUR, PLN, GBP) |

## Przykłady użycia

### 1. Zapytanie o dane dla USD
```bash
curl "/.netlify/functions/inflation?currency=USD"
```

### 2. Zapytanie o dane dla PLN
```bash
curl "/.netlify/functions/inflation?currencyCode=PLN"
```

### 3. Użycie w JavaScript (frontend)
```javascript
fetch('/.netlify/functions/inflation?currency=EUR')
  .then(response => response.json())
  .then(data => {
    console.log('Dane inflacyjne:', data);
  })
  .catch(error => {
    console.error('Błąd:', error);
  });
```

## Odpowiedź API

### Sukces (status 200)
```json
{
  "currencyCode": "USD",
  "countryCode": "US",
  "dataAvailablePeriod": "1990-2023",
  "statistics": {
    "mean": 2.41,
    "standardDeviation": 0.48
  },
  "rawData": {
    "yearlyInflationRates": [2.1, 1.9, 2.3, 2.8, 3.1, 2.4, 1.8, 2.5, 2.2, 1.7, 2.9, 3.2, 2.6],
    "dataPoints": 13
  }
}
```

### Błąd - Brak kodu waluty (status 400)
```json
{
  "error": "Brak kodu waluty. Użyj parametru ?currency=USD lub ?currencyCode=USD",
  "message": "Currency code is required. Use ?currency=USD or ?currencyCode=USD"
}
```

### Błąd - Waluta nie znaleziona (status 404)
```json
{
  "error": "Dane inflacyjne dla waluty XYZ nie zostały znalezione",
  "message": "Inflation data for currency XYZ not found",
  "availableCurrencies": ["USD", "EUR", "PLN", "GBP"]
}
```

## Dostępne waluty
Aktualnie endpoint obsługuje następujące waluty:
- **USD** (Dolar amerykański) - dane za okres 1990-2023
- **EUR** (Euro) - dane za okres 1999-2023
- **PLN** (Złoty polski) - dane za okres 1995-2023
- **GBP** (Funt brytyjski) - dane za okres 1990-2023

## Struktura danych

| Pole | Typ | Opis |
|------|-----|------|
| `currencyCode` | string | Kod waluty (3 litery) |
| `countryCode` | string | Kod kraju/regionu |
| `dataAvailablePeriod` | string | Okres dla którego dostępne są dane |
| `statistics.mean` | number | Średnia arytmetyczna inflacji (%) |
| `statistics.standardDeviation` | number | Odchylenie standardowe (%) |
| `rawData.yearlyInflationRates` | array | Roczne stopy inflacji |
| `rawData.dataPoints` | number | Liczba punktów danych |

## Nagłówki CORS
Endpoint jest skonfigurowany z nagłówkami CORS umożliwiającymi dostęp z różnych domen:
- `Access-Control-Allow-Origin: *`
- `Access-Control-Allow-Headers: Content-Type`
- `Access-Control-Allow-Methods: GET, POST, OPTIONS`

## Uwagi techniczne
- Dane są obecnie przechowywane w pamięci jako obiekt JavaScript
- W przyszłości powinny zostać przeniesione do właściwej bazy danych
- Wszystkie kody walut są automatycznie konwertowane na wielkie litery
- Endpoint obsługuje zarówno parametr `currency` jak i `currencyCode`

## Rozwój
Aby dodać nową walutę, należy:
1. Dodać nowy obiekt do `inflationDatabase` w pliku `lambda/inflation.js`
2. Podać wymagane pola: `currencyCode`, `countryCode`, `dataAvailablePeriod`, `yearlyData`, `mean`, `standardDeviation`
3. Upewnić się, że wartości `mean` i `standardDeviation` są poprawnie obliczone