export interface Shop {
  id: string
  token: string
  name: string
  description: string
  returnUrl?: string
  applePayMerchantIdentifier?: string
  applicationScheme?: string
}
