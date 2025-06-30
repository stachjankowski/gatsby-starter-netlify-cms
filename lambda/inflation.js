const { Pool } = require('pg');

// Konfiguracja połączenia z bazą danych PostgreSQL
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

// Funkcja do obliczania średniej
const calculateMean = (values) => {
  return values.reduce((sum, value) => sum + value, 0) / values.length;
};

// Funkcja do obliczania odchylenia standardowego
const calculateStandardDeviation = (values, mean) => {
  const squaredDifferences = values.map(value => Math.pow(value - mean, 2));
  const variance = squaredDifferences.reduce((sum, value) => sum + value, 0) / values.length;
  return Math.sqrt(variance);
};

module.exports.handler = async function(event, context) {
  // Nagłówki CORS
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Content-Type': 'application/json',
  };

  try {
    // Obsługa zapytań OPTIONS (CORS preflight)
    if (event.httpMethod === 'OPTIONS') {
      return {
        statusCode: 200,
        headers,
        body: '',
      };
    }

    // Tylko metoda GET jest dozwolona
    if (event.httpMethod !== 'GET') {
      return {
        statusCode: 405,
        headers,
        body: JSON.stringify({ error: 'Metoda nie jest dozwolona' }),
      };
    }

    // Pobieranie parametru currency_code z query string
    const { currency_code } = event.queryStringParameters || {};

    if (!currency_code) {
      return {
        statusCode: 400,
        headers,
        body: JSON.stringify({ 
          error: 'Parametr currency_code jest wymagany',
          example: '/.netlify/functions/inflation?currency_code=PLN'
        }),
      };
    }

    // Walidacja kodu waluty (3 znaki, wielkie litery)
    if (!/^[A-Z]{3}$/.test(currency_code)) {
      return {
        statusCode: 400,
        headers,
        body: JSON.stringify({ 
          error: 'Kod waluty musi składać się z 3 wielkich liter (np. PLN, USD, EUR)' 
        }),
      };
    }

    const client = await pool.connect();

    try {
      // Pobieranie danych o inflacji dla zadanej waluty
      const inflationQuery = `
        SELECT 
          i.inflation_rate,
          i.year,
          i.month,
          c.currency_code,
          c.country_code,
          c.country_name
        FROM inflation_data i
        JOIN currencies c ON i.currency_id = c.id
        WHERE c.currency_code = $1
        ORDER BY i.year DESC, i.month DESC
      `;

      const result = await client.query(inflationQuery, [currency_code]);

      if (result.rows.length === 0) {
        return {
          statusCode: 404,
          headers,
          body: JSON.stringify({ 
            error: `Nie znaleziono danych o inflacji dla waluty ${currency_code}`,
            available_currencies_info: 'Sprawdź dostępne waluty w bazie danych'
          }),
        };
      }

      // Przygotowanie danych
      const firstRow = result.rows[0];
      const inflationRates = result.rows.map(row => parseFloat(row.inflation_rate));
      
      // Znajdowanie zakresu dat
      const dates = result.rows.map(row => ({ year: row.year, month: row.month }));
      const sortedDates = dates.sort((a, b) => {
        if (a.year !== b.year) return a.year - b.year;
        return a.month - b.month;
      });
      
      const earliestDate = sortedDates[0];
      const latestDate = sortedDates[sortedDates.length - 1];

      // Obliczanie statystyk
      const mean = calculateMean(inflationRates);
      const standardDeviation = calculateStandardDeviation(inflationRates, mean);

      // Przygotowanie odpowiedzi
      const response = {
        currency_code: firstRow.currency_code,
        country_code: firstRow.country_code,
        country_name: firstRow.country_name,
        data_period: {
          from: {
            year: earliestDate.year,
            month: earliestDate.month
          },
          to: {
            year: latestDate.year,
            month: latestDate.month
          },
          total_months: result.rows.length
        },
        statistics: {
          mean: parseFloat(mean.toFixed(4)),
          standard_deviation: parseFloat(standardDeviation.toFixed(4)),
          min: Math.min(...inflationRates),
          max: Math.max(...inflationRates)
        },
        data_count: result.rows.length,
        last_updated: new Date().toISOString()
      };

      return {
        statusCode: 200,
        headers,
        body: JSON.stringify(response),
      };

    } finally {
      client.release();
    }

  } catch (error) {
    console.error('Błąd w endpoint inflation:', error);
    
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ 
        error: 'Błąd wewnętrzny serwera',
        message: process.env.NODE_ENV === 'development' ? error.message : 'Wystąpił nieoczekiwany błąd'
      }),
    };
  }
};