# GOLD BREAKOUT EXPERT ADVISOR


Description:
------------
This Expert Advisor (EA) is designed for **breakout traders** who want 
to automate entries based on **key support and resistance levels**. 
It implements a fixed **1:5 risk-reward ratio**, targeting high reward 
trades with tight stop-losses and confirmed breakouts.

Developed for MetaTrader 5 (MT5), this strategy dynamically scans 
historical price data to detect **strong support and resistance zones** 
and then places trades when price breaks out with momentum.

------------------------------------------------------------
Core Strategy Logic:
------------------------------------------------------------

1. **Support/Resistance Detection**
   - Looks back over the last `LookbackPeriod` bars
   - Finds highs/lows with repeated price rejections
   - Filters valid levels based on `MinTouchCount`

2. **Breakout Confirmation**
   - Uses `BreakoutMultiplier` to confirm that price has moved 
     beyond the level by a certain threshold (e.g., 1.2 = 20% of a pip)

3. **Trade Execution**
   - Buy when price breaks above resistance
   - Sell when price breaks below support
   - SL = 20 pips buffer beyond the breakout level
   - TP = 5x the risk (1:5 risk-to-reward)

4. **Risk Management**
   - Fixed lot size (`LotSize`)
   - Maximum trade duration controlled by `MaxTradeDuration`
   - Prevents duplicate trades on the same bar

------------------------------------------------------------
Input Parameters:
------------------------------------------------------------

* LotSize             : Fixed lot size for trades
* LookbackPeriod      : Number of candles to scan for levels
* MinTouchCount       : Required touchpoints for valid S/R level
* BreakoutMultiplier  : Percentage move beyond S/R for breakout
* MaxTradeDuration    : Max hours to keep a position open
* MagicNumber         : Unique identifier for trades
* Slippage            : Maximum slippage in points
* TradeComment        : Trade comment for identification
* EnableDebug         : Toggle verbose console logging

------------------------------------------------------------
Trade Examples:
------------------------------------------------------------

• Price forms resistance at 1.1000 (3 touches).
• Price breaks above 1.1000 by > BreakoutMultiplier.
• EA places a **buy trade** at the ask price.
• SL set ~20 pips below breakout level.
• TP set at 5x the risk.

Opposite logic applies for **support breakouts** (sell trades).

------------------------------------------------------------
File Summary:
------------------------------------------------------------

- **BreakoutTradingStrategy.mq5**
  → Main EA source file with full strategy logic and trade execution.

------------------------------------------------------------
Best Use Cases:
------------------------------------------------------------

✓ Trend continuation breakouts  
✓ Consolidation breakout scalping  
✓ High R:R challenge accounts or funding tests  

**Recommended Timeframes:** M15, M30, H1  
**Pairs:** Major forex pairs, indices, gold

------------------------------------------------------------
License & Credit:
------------------------------------------------------------

Author      : Breakout Trading EA Team  
Version     : 1.10  
Year        : 2024  
License     : MIT (Free for personal and commercial use)

------------------------------------------------------------
Note:
------------------------------------------------------------

• Always test in a demo environment before going live.  
• Tune `LookbackPeriod` and `BreakoutMultiplier` based on instrument.  
• Use with proper risk and account management.

============================================================
         For updates and questions, contribute on GitHub!
============================================================
