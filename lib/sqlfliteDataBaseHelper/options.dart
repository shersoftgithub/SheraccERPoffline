class optionsDBHelper {
  static List<String> optionOnline = [
    "Ledger Registration",
    "Payment",
    "Receipt",
    "Sales",
    "Purchase",
    "Stock",
    "Journal",
    "Ledger Report",
    "Payment Report",
    "Receipt Report",
    "Journal Report",
    "Purchase Report",
    "Sales Report",
    "Stock Report",
    "Unit Registration",
    "Group Registration",
    "Product Register",
    "Manufacture Registration",
    "Group List",
    "Purchase List",
    "Sales List",
    "SerialNo Report",
    "Vehicle Register",
    "Stock Summary",
    "PurchaseReturn",
    "Stock Management",
    "Product Management"
  ];

  static List<String> priceLevel = [
    "QTY", "WS", "SRATE", "MRP", "RETAIL", "SPRETAIL", "BRANCH", "PRATE", "UniqueCode", "Supplier", "More"
  ];

  static List<String> salesForm = [
    "Sales ES",
    "Sales B2B",
    "Sales B2C",
    "Bill of Supply",
    "Sales IS",
    "Sales Order",
    "Sales Quotation"
  ];

  static List<String> salesReportType = [
    "Summary",
    "Sales Daily",
    "Sales Itemwise",
    "Item Summery",
    "P&L Summary",
    "P&L ItemWise",
    "P&L ItemSimple",
    "Packing Slip",
    "Customer Summary",
    "Daily Sales Tax Report",
    "IVA Report",
    "Customer Summery Invoice",
    "Counter Wise Report",
    "Replace P&L Itemwise",
    "Simple P&L Report",
    "Scheme Report",
    "Itemwise Monthly",
    "P&L Itemwise New",
    "Customer Address",
    "Insurance Report",
    "Sales Qty Total",
    "Group Summery Custom",
    "P&L monthly",
    "ItemWise Rate Analysis",
    "Itemwise Profit Analysis",
    "Sales E-Invoice Report",
    "Month Wise Item Summary ",
    "Supplier Wise Sales Total",
    "sales Item wise Customer",
    "Sales Summary DC",
    "Sales Monthly",
    "DeliveryNote Summary"
  ];

  static List<String> purchaseReportType = [
    "Summary", "ItemWise", "Capital Summary", "Expense Summary", "ItemWise Comparison Stock Rate"
  ];

  static List<String> stockReportType = [
    "Summary", "Sales ItemWise", "Packing Slip"
  ];

  Future<List<String>> getOptionsByType(String type) async {
    switch (type) {
      case 'Option_online':
        return optionOnline;
      case 'price_level':
        return priceLevel;
      case 'sales_form':
        return salesForm;
      case 'sales_reporttype':
        return salesReportType;
      case 'purcahse_reportType':
        return purchaseReportType;
      case 'Stock_reportType':
        return stockReportType;
      default:
        return [];
    }
  }
}
