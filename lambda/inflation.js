// Inflation data endpoint for kalkulatoremerytalny-backend
// Returns inflation data for a given currency

// Mock database with inflation data
// In a real application, this would come from a proper database
const inflationDatabase = {
  'USD': {
    currencyCode: 'USD',
    countryCode: 'US',
    dataAvailablePeriod: '1990-2023',
    yearlyData: [2.1, 1.9, 2.3, 2.8, 3.1, 2.4, 1.8, 2.5, 2.2, 1.7, 2.9, 3.2, 2.6],
    mean: 2.41,
    standardDeviation: 0.48
  },
  'EUR': {
    currencyCode: 'EUR',
    countryCode: 'EU',
    dataAvailablePeriod: '1999-2023',
    yearlyData: [1.8, 2.1, 1.6, 2.4, 2.7, 1.9, 1.5, 2.2, 1.9, 1.4, 2.6, 2.9, 2.3],
    mean: 2.08,
    standardDeviation: 0.46
  },
  'PLN': {
    currencyCode: 'PLN',
    countryCode: 'PL',
    dataAvailablePeriod: '1995-2023',
    yearlyData: [3.2, 2.8, 3.5, 4.1, 3.6, 2.9, 2.4, 3.8, 3.4, 2.7, 4.2, 4.6, 3.9],
    mean: 3.47,
    standardDeviation: 0.68
  },
  'GBP': {
    currencyCode: 'GBP',
    countryCode: 'GB',
    dataAvailablePeriod: '1990-2023',
    yearlyData: [2.4, 2.1, 2.7, 3.2, 2.8, 2.3, 1.9, 2.6, 2.3, 1.8, 3.1, 3.5, 2.9],
    mean: 2.58,
    standardDeviation: 0.51
  }
};

// Helper function to calculate statistics (if needed to recalculate)
function calculateStatistics(data) {
  const mean = data.reduce((sum, value) => sum + value, 0) / data.length;
  const variance = data.reduce((sum, value) => sum + Math.pow(value - mean, 2), 0) / data.length;
  const standardDeviation = Math.sqrt(variance);
  
  return {
    mean: Math.round(mean * 100) / 100,
    standardDeviation: Math.round(standardDeviation * 100) / 100
  };
}

// Main handler function
module.exports.handler = async function(event, context) {
  console.log("Inflation endpoint called", event.queryStringParameters);
  
  try {
    // Get currency code from query parameters
    const currencyCode = event.queryStringParameters?.currency || event.queryStringParameters?.currencyCode;
    
    if (!currencyCode) {
      return {
        statusCode: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Headers': 'Content-Type',
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS'
        },
        body: JSON.stringify({
          error: 'Brak kodu waluty. Użyj parametru ?currency=USD lub ?currencyCode=USD',
          message: 'Currency code is required. Use ?currency=USD or ?currencyCode=USD'
        })
      };
    }

    // Convert to uppercase for consistency
    const upperCurrencyCode = currencyCode.toUpperCase();
    
    // Check if currency exists in database
    const inflationData = inflationDatabase[upperCurrencyCode];
    
    if (!inflationData) {
      return {
        statusCode: 404,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Headers': 'Content-Type',
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS'
        },
        body: JSON.stringify({
          error: `Dane inflacyjne dla waluty ${upperCurrencyCode} nie zostały znalezione`,
          message: `Inflation data for currency ${upperCurrencyCode} not found`,
          availableCurrencies: Object.keys(inflationDatabase)
        })
      };
    }

    // Return the inflation data
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS'
      },
      body: JSON.stringify({
        currencyCode: inflationData.currencyCode,
        countryCode: inflationData.countryCode,
        dataAvailablePeriod: inflationData.dataAvailablePeriod,
        statistics: {
          mean: inflationData.mean,
          standardDeviation: inflationData.standardDeviation
        },
        // Optional: include raw data for additional analysis
        rawData: {
          yearlyInflationRates: inflationData.yearlyData,
          dataPoints: inflationData.yearlyData.length
        }
      })
    };

  } catch (error) {
    console.error('Error in inflation endpoint:', error);
    
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS'
      },
      body: JSON.stringify({
        error: 'Błąd wewnętrzny serwera',
        message: 'Internal server error'
      })
    };
  }
};

// Handle OPTIONS requests for CORS
if (module.exports.handler.toString().includes('OPTIONS')) {
  // OPTIONS requests are handled in the main handler
}