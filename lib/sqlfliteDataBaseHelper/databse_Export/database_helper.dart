// public class DBHelper extends SQLiteOpenHelper {

//     String TakeToday = "2000/01/01";
//     private static final String LOGCAT = null;
//     Date date;
//     //context
//     private final Context mContext;

//     //table
//     static String[] TableName = { "Stock"};
//     public static String[][] ColumnName = {
//                   {"ItemName", "ItemCode", "PRate", "SRate", "MRP", "Retail", "WS", "Branch", "Qty", "Tax", "Firm", "IMG", "IMGURL", "SerialNo", "HSN", "ID", "Uniquecode", "Rate", "stockvaluation", "negativestockstatus", "Unit", "Mfr", "Location", "obarcode", "spretail","cessper","adcess","MLM","RPRate","Supplier"},//Stock

//     };
//      public static String[][] ColumnContent = {
//                   {"ItemName TEXT default('')", "ItemCode TEXT default('')", "PRate REAL default('0')", "SRate REAL default('0')", "MRP REAL default('0')", "Retail REAL default('0')", "WS REAL default('0')", "Branch REAL default('0')", "Qty REAL default('0')", "Tax REAL default('0')", "Firm TEXT default('')", "IMG TEXT default('')", "IMGURL TEXT default('')", "SerialNo TEXT default('')", "HSN TEXT default('')", "ID INTEGER PRIMARY KEY AUTOINCREMENT", "Uniquecode TEXT default('')", "Rate REAL default(0)", "stockvaluation TEXT default('')", "negativestockstatus INTEGER default(0)", "Unit TEXT default('')", "Mfr TEXT default('')", "Location TEXT default('')", "obarcode TEXT default('')", "spretail REAL default(0)","cessper REAL default(0)","adcess REAL default(0)","MLM TEXT default('')","RPRate REAL default(0)","Supplier TEXT default('')"},//Stock

//      };
//       public DBHelper(Context context) {
//         super(context, "SherAccERP.db", null, 1);
//         Log.d(LOGCAT, "DB Created");
//         mContext = context;
//         walDisable();
//         waljournalDelete();
//     }
//      @Override
//     public void onCreate(SQLiteDatabase db) {
//               db.execSQL("CREATE TABLE IF NOT EXISTS Stock(ItemName TEXT,ItemCode TEXT,PRate REAL,SRate REAL,MRP REAL,Retail REAL,WS REAL,Branch REAL,Qty REAL,Tax REAL,Firm TEXT,IMG TEXT,IMGURL TEXT,SerialNo TEXT,HSN TEXT,ID INTEGER PRIMARY KEY AUTOINCREMENT,Uniquecode TEXT,Rate REAL,stockvaluation TEXT,negativestockstatus INTEGER default(0),Unit TEXT,Mfr TEXT,Location TEXT,obarcode TEXT,spretail REAL default(0),cessper REAL default(0),adcess REAL default(0),MLM TEXT default(''),RPRate REAL default(0),Supplier  TEXT default(''))");

//     }

