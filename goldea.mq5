//+------------------------------------------------------------------+
//|                     BreakoutTradingStrategy.mq5                  |
//|                        Copyright 2024, Breakout Trading EA       |
//|                                   1:5 Risk-Reward Ratio Version  |
//+------------------------------------------------------------------+
#property copyright "Breakout Trading Strategy"
#property link      ""
#property version   "1.10"

//+------------------------------------------------------------------+
//| Input Parameters                                                |
//+------------------------------------------------------------------+
input double   LotSize=0.01;            // Lot size
input int      LookbackPeriod=30;       // Bars to analyze for S/R
input int      MinTouchCount=2;         // Minimum touches for valid level
input double   BreakoutMultiplier=1.2;  // Breakout confirmation (1.2 = 20% beyond level)
input int      MaxTradeDuration=1;     // Max trade duration in hours
input int      MagicNumber=987654;      // EA Magic Number
input int      Slippage=10;             // Slippage in points
input string   TradeComment="Breakout1:5"; // Trade comment
input bool     EnableDebug=true;        // Enable debug prints

//+------------------------------------------------------------------+
//| Global Variables                                                |
//+------------------------------------------------------------------+
datetime lastBarTime;
double lastResistance=0;
double lastSupport=0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(EnableDebug) Print("Breakout Trading EA Initialized");
   lastBarTime=0;
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   datetime currentBarTime=iTime(NULL,PERIOD_CURRENT,0);
   if(currentBarTime==lastBarTime) return;
   lastBarTime=currentBarTime;
   
   string symbol=Symbol();
   if(EnableDebug) Print("New bar - Analyzing ",symbol," at ",TimeToString(currentBarTime));
   
   // Check for existing positions
   if(PositionSelect(symbol))
     {
      if(EnableDebug) Print("Position already exists - skipping analysis");
      return;
     }
   
   // Find key support/resistance levels
   FindKeyLevels(symbol);
   
   // Check for breakouts
   CheckForBreakouts(symbol);
  }

//+------------------------------------------------------------------+
//| Find key support/resistance levels                               |
//+------------------------------------------------------------------+
void FindKeyLevels(string symbol)
  {
   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   CopyRates(symbol,PERIOD_CURRENT,0,LookbackPeriod,rates);
   
   // Find resistance levels (price rejections at similar highs)
   double resistanceLevels[];
   int resistanceCounts[];
   
   // Find support levels (price rejections at similar lows)
   double supportLevels[];
   int supportCounts[];
   
   // Analyze price action to find levels
   for(int i=0; i<LookbackPeriod; i++)
     {
      // Check for resistance candidates
      bool isResistance=true;
      for(int j=i-1; j>=0 && j>=i-3; j--)
        {
         if(rates[i].high<rates[j].high)
           {
            isResistance=false;
            break;
           }
        }
      if(isResistance)
        {
         AddToLevelArray(rates[i].high,resistanceLevels,resistanceCounts);
        }
        
      // Check for support candidates
      bool isSupport=true;
      for(int j=i-1; j>=0 && j>=i-3; j--)
        {
         if(rates[i].low>rates[j].low)
           {
            isSupport=false;
            break;
           }
        }
      if(isSupport)
        {
         AddToLevelArray(rates[i].low,supportLevels,supportCounts);
        }
     }
   
   // Find strongest resistance (most touches)
   lastResistance=0;
   int maxResistanceTouches=0;
   for(int i=0; i<ArraySize(resistanceLevels); i++)
     {
      if(resistanceCounts[i]>maxResistanceTouches && resistanceCounts[i]>=MinTouchCount)
        {
         maxResistanceTouches=resistanceCounts[i];
         lastResistance=resistanceLevels[i];
        }
     }
   
   // Find strongest support (most touches)
   lastSupport=0;
   int maxSupportTouches=0;
   for(int i=0; i<ArraySize(supportLevels); i++)
     {
      if(supportCounts[i]>maxSupportTouches && supportCounts[i]>=MinTouchCount)
        {
         maxSupportTouches=supportCounts[i];
         lastSupport=supportLevels[i];
        }
     }
   
   if(EnableDebug)
     {
      Print("Key Levels Found:");
      Print("  Resistance: ",lastResistance," (",maxResistanceTouches," touches)");
      Print("  Support: ",lastSupport," (",maxSupportTouches," touches)");
     }
  }

//+------------------------------------------------------------------+
//| Add price level to array or increment count if exists            |
//+------------------------------------------------------------------+
void AddToLevelArray(double level,double &levels[],int &counts[])
  {
   int size=ArraySize(levels);
   bool found=false;
   
   // Allow some tolerance for level matching
   double tolerance=10*_Point;
   
   for(int i=0; i<size; i++)
     {
      if(MathAbs(levels[i]-level)<=tolerance)
        {
         counts[i]++;
         found=true;
         break;
        }
     }
   
   if(!found)
     {
      ArrayResize(levels,size+1);
      ArrayResize(counts,size+1);
      levels[size]=level;
      counts[size]=1;
     }
  }

//+------------------------------------------------------------------+
//| Check for breakout opportunities                                 |
//+------------------------------------------------------------------+
void CheckForBreakouts(string symbol)
  {
   double currentAsk=SymbolInfoDouble(symbol,SYMBOL_ASK);
   double currentBid=SymbolInfoDouble(symbol,SYMBOL_BID);
   
   // Check for resistance breakout (long)
   if(lastResistance>0 && currentAsk>(lastResistance*(1+BreakoutMultiplier*_Point)))
     {
      double entryPrice=currentAsk;
      double stopLoss=lastResistance-(lastResistance*0.0020); // 20 pips below resistance
      double takeProfit=entryPrice+(5*(entryPrice-stopLoss)); // 1:5 risk-reward
      
      if(EnableDebug)
        {
         Print("Resistance Breakout Detected!");
         Print("  Entry: ",entryPrice);
         Print("  Stop Loss: ",stopLoss);
         Print("  Take Profit: ",takeProfit);
        }
      
      SendOrder(ORDER_TYPE_BUY,symbol,entryPrice,stopLoss,takeProfit);
     }
   
   // Check for support breakout (short)
   if(lastSupport>0 && currentBid<(lastSupport*(1-BreakoutMultiplier*_Point)))
     {
      double entryPrice=currentBid;
      double stopLoss=lastSupport+(lastSupport*0.0020); // 20 pips above support
      double takeProfit=entryPrice-(5*(stopLoss-entryPrice)); // 1:5 risk-reward
      
      if(EnableDebug)
        {
         Print("Support Breakout Detected!");
         Print("  Entry: ",entryPrice);
         Print("  Stop Loss: ",stopLoss);
         Print("  Take Profit: ",takeProfit);
        }
      
      SendOrder(ORDER_TYPE_SELL,symbol,entryPrice,stopLoss,takeProfit);
     }
  }

//+------------------------------------------------------------------+
//| Send trade order                                                 |
//+------------------------------------------------------------------+
bool SendOrder(ENUM_ORDER_TYPE orderType,string symbol,double price,double sl,double tp)
  {
   MqlTradeRequest request;
   MqlTradeResult result;
   ZeroMemory(request);
   ZeroMemory(result);
   
   request.action=TRADE_ACTION_DEAL;
   request.symbol=symbol;
   request.volume=LotSize;
   request.type=orderType;
   request.price=price;
   request.sl=sl;
   request.tp=tp;
   request.deviation=Slippage;
   request.magic=MagicNumber;
   request.comment=TradeComment;
   request.type_time=ORDER_TIME_GTC;
   request.type_filling=ORDER_FILLING_FOK;
   
   if(EnableDebug) Print("Sending ",EnumToString(orderType)," order...");
   
   bool success=OrderSend(request,result);
   
   if(success)
     {
      if(EnableDebug) Print("Order successful! Ticket: ",result.order);
      return true;
     }
   else
     {
      if(EnableDebug) Print("Order failed! Error: ",GetLastError());
      return false;
     }
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(EnableDebug) Print("EA Deinitialized");
  }
//+------------------------------------------------------------------+



//DO NOT USE THIS CODE TO TAKE TRADES, NOT A FINANCIAL ADVISOR
