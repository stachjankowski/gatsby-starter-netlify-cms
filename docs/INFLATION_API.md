# API Danych o Inflacji

## Endpoint: `/inflation`

Endpoint zwracający dane o inflacji dla zadanej waluty wraz z podstawowymi statystykami.

### Metoda HTTP
`GET`

### Parametry Query String

| Parametr | Typ | Wymagany | Opis |
|----------|-----|----------|------|
| `currency_code` | string | Tak | 3-literowy kod waluty (np. PLN, USD, EUR) |

### Przykład żądania

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
    "from": {
      "year": 2020,
      "month": 1
    },
    "to": {
      "year": 2023,
      "month": 12
    },
    "total_months": 48
  },
  "statistics": {
    "mean": 8.2458,
    "standard_deviation": 5.2341,
    "min": 2.4,
    "max": 18.4
  },
  "data_count": 48,
  "last_updated": "2023-12-30T10:15:30.000Z"
}
```

### Kody odpowiedzi

| Kod | Opis |
|-----|------|
| 200 | Sukces - zwrócono dane o inflacji |
| 400 | Błąd walidacji - nieprawidłowy lub brakujący parametr currency_code |
| 404 | Nie znaleziono danych dla podanej waluty |
| 500 | Błąd wewnętrzny serwera |

### Obsługiwane waluty

Aktualnie API obsługuje następujące waluty:
- **PLN** - Polski złoty (Polska)
- **USD** - Dolar amerykański (Stany Zjednoczone)
- **EUR** - Euro (Unia Europejska)
- **GBP** - Funt brytyjski (Wielka Brytania)
- **JPY** - Jen japoński (Japonia)
- **CHF** - Frank szwajcarski (Szwajcaria)
- **CAD** - Dolar kanadyjski (Kanada)
- **AUD** - Dolar australijski (Australia)

### Struktura danych

#### Obiekt główny
- `currency_code` - 3-literowy kod waluty
- `country_code` - 2-literowy kod kraju (ISO 3166-1 alpha-2)
- `country_name` - pełna nazwa kraju
- `data_period` - obiekt zawierający informacje o okresie, za który dostępne są dane
- `statistics` - obiekt zawierający obliczone statystyki
- `data_count` - liczba dostępnych punktów danych
- `last_updated` - znacznik czasu ostatniej aktualizacji odpowiedzi

#### Obiekt `data_period`
- `from` - data początku dostępnych danych
- `to` - data końca dostępnych danych
- `total_months` - łączna liczba miesięcy z danymi

#### Obiekt `statistics`
- `mean` - średnia arytmetyczna stopy inflacji
- `standard_deviation` - odchylenie standardowe
- `min` - minimalna wartość inflacji w okresie
- `max` - maksymalna wartość inflacji w okresie

### Błędy

#### Brakujący parametr currency_code
```json
{
  "error": "Parametr currency_code jest wymagany",
  "example": "/.netlify/functions/inflation?currency_code=PLN"
}
```

#### Nieprawidłowy format kodu waluty
```json
{
  "error": "Kod waluty musi składać się z 3 wielkich liter (np. PLN, USD, EUR)"
}
```

#### Nie znaleziono danych
```json
{
  "error": "Nie znaleziono danych o inflacji dla waluty XYZ",
  "available_currencies_info": "Sprawdź dostępne waluty w bazie danych"
}
```

### Użycie w JavaScript

```javascript
// Funkcja do pobierania danych o inflacji
async function getInflationData(currencyCode) {
  try {
    const response = await fetch(`/.netlify/functions/inflation?currency_code=${currencyCode}`);
    
    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(errorData.error || 'Błąd podczas pobierania danych');
    }
    
    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Błąd:', error.message);
    throw error;
  }
}

// Przykład użycia
getInflationData('PLN')
  .then(data => {
    console.log(`Średnia inflacja dla ${data.currency_code}: ${data.statistics.mean}%`);
    console.log(`Dane dostępne od ${data.data_period.from.month}/${data.data_period.from.year} do ${data.data_period.to.month}/${data.data_period.to.year}`);
  })
  .catch(error => {
    console.error('Nie udało się pobrać danych:', error.message);
  });
```

### Uwagi techniczne

- API używa połączenia z bazą danych PostgreSQL
- Dane są buforowane na poziomie bazy danych dla lepszej wydajności
- Wszystkie odpowiedzi zawierają odpowiednie nagłówki CORS
- Czas odpowiedzi wynosi średnio 200-500ms
- API obsługuje zapytania OPTIONS dla preflightów CORS