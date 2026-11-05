// =============================================================================
// Budget med varningar - på PRENUMERATIONSNIVÅ.
//
// Ligger på prenumerationen (inte i en resource group), så budgeten finns kvar
// när ni river ned resource groups varje kväll. Deploya med:
//   az deployment sub create --location swedencentral --template-file budget.bicep --parameters contactEmail=<e-post>
//
// En budget VARNAR - den stoppar inte något.
// =============================================================================
targetScope = 'subscription'

param budgetName string = 'budget-azurekurs'

@description('Belopp per månad, i prenumerationens valuta.')
param amount int = 10

@description('E-postadressen som får varningarna.')
param contactEmail string

@description('Första dagen i månaden. Standard: innevarande månad.')
param startDate string = '${utcNow('yyyy-MM')}-01T00:00:00Z'

resource budget 'Microsoft.Consumption/budgets@2023-05-01' = {
  name: budgetName
  properties: {
    category: 'Cost'
    amount: amount
    timeGrain: 'Monthly'
    timePeriod: {
      startDate: startDate
    }
    notifications: {
      actual50: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 50
        thresholdType: 'Actual'
        contactEmails: [
          contactEmail
        ]
      }
      actual80: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 80
        thresholdType: 'Actual'
        contactEmails: [
          contactEmail
        ]
      }
      forecast100: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 100
        thresholdType: 'Forecasted'
        contactEmails: [
          contactEmail
        ]
      }
    }
  }
}

output budgetId string = budget.id
