/*========DESCRIÇÃO Martingale 1.0====== 

  
=======================*/

/*=======================================================ANOTAÇÕES========================================================


========================================================================================================================*/
extern double Lots = 0.01;
extern int lotdecimal = 2; 
extern double LotExponent = 2; 


int ticket,MagicNumber,total,NumOfTrades;
double iLots;
int OnInit(){return(INIT_SUCCEEDED);}
  
void OnTick()
  {     
      //========================POINT===============================
               double MyPoint=Point;                                      
               if(Digits==3 || Digits==5) MyPoint=Point*10;               
      //============================================================
      double MA = iMA(Symbol(),NULL,5,0,MODE_SMA,PRICE_CLOSE,0);
      
   total = CountTrades();
   NumOfTrades = total;
   iLots = NormalizeDouble(Lots * MathPow(LotExponent, NumOfTrades), lotdecimal);  //acredito q eu deva alterar isso.
    
    if(OrdersTotal()==0) 
    {
      if(Bid<MA)
      {
       ticket = OrderSend(Symbol(),OP_SELL,iLots,Bid,0,0,0,NULL,MagicNumber,0,Red);
      
      } 
    }    
    
            for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
            if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES)) {
            
               if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
               {
                  if(OrderType()==OP_SELL)
                  {
                     if(Bid-10*MyPoint>OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_SELL,iLots,Bid,0,0,NULL,MagicNumber,0,Red);
                     break;
                  }
                  
               } 
               }     
               }
         
             int cntt, totalt=OrdersTotal();
            for(cntt=0;cntt<totalt;cntt++)
            {
               if(OrderSelect(cntt,SELECT_BY_POS,MODE_TRADES))
               if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
               {
                  if(OrderType()==OP_SELL)
                  {
                  double a = OrderOpenPrice();
                     ticket = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),a-3*NumOfTrades*MyPoint  ,0,clrAliceBlue);
                     }}}
                     
                   //a- MathPow(3, NumOfTrades)*MyPoint  
         
        /* for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
         if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES)) {
            
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == MagicNumber) {
               if (OrderType() == OP_SELL)
               {
               double a = OrderOpenPrice();
                  if(Bid-10*MyPoint>OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_SELL,iLots,Bid,0,0,,NULL,MagicNumber,0,Red);
                  
                  break;
               }
               }
               }
               }
          //a- MathPow(3, NumOfTrades)*MyPoint     
               */
      
                  
     
      
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA ORDEM++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++       


  
  
  
  
  
  
  
  
  
  
  
  }//FIM ONTICK
  
//Contar quantas ordens existe em aberto
  
   int CountTrades() {
   int count = 0;
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) 
   {
      int a = OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) count++;
   }
   return (count);
}

