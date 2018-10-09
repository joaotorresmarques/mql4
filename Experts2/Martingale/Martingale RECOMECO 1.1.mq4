//AUMENTA O LOTE
string Robo = "Martingale RECOMECO";
extern int Slippage = 0;
extern int MagicNumber = 121212;

extern int TAKE = 5;
extern int STOP = 3;

extern double Lots = 0.01;

double Spread=MarketInfo(Symbol(),MODE_SPREAD);


int ticket,NumOfTrades;
datetime tempo;
double iLots;
double Balancoanterior;

int OnInit(){return(INIT_SUCCEEDED);}
  
void OnTick()
  {     

//=========================POINT
      double MyPoint=Point;                                      
      if(Digits==3 || Digits==5) MyPoint=Point*10;               
      
//=========================MEDIAS MOVEIS
     
      double MAopen = iMA(Symbol(),NULL,9,0,MODE_EMA,PRICE_OPEN,0);
      double MAclose = iMA(Symbol(),NULL,9,0,MODE_EMA,PRICE_CLOSE,0); 
      double MAmedia = iMA(Symbol(),NULL,21,0,MODE_EMA,PRICE_CLOSE,0);
//=========================LOTES
      NumOfTrades = CountTrades();
      iLots = Lots+(NumOfTrades*0.01); 
      

//=========================LOTES2
 if(AccountBalance()>Balancoanterior) //if(AccountBalance()>Balancoanterior/*+606+909+808*/)
 {                                    
    iLots = iLots;
 }
      static int closedOrders2=0;
      if(OrdersHistoryTotal()!=closedOrders2)
      {
         closedOrders2=OrdersHistoryTotal();
         int hstTotal2 = OrdersHistoryTotal(); 
        
         if(OrderSelect(hstTotal2-1,SELECT_BY_POS,MODE_HISTORY))
         if(OrderType()==OP_SELL || OrderType()==OP_BUY)
         {
            if(OrderLots()>= 0.15)
            {
              
              Balancoanterior = AccountBalance();
               
             iLots=1.0;
            }
            
           
         } //FIM SELEÇÃO OP_SELL
         
        
         
      }//FIM ORDERHISTORYTOTAL()
      
      
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++FECHAR TODAS ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
   
      
         static int closedOrders=0;
         if(OrdersHistoryTotal()!=closedOrders)
         {
            closedOrders=OrdersHistoryTotal();
            int hstTotal = OrdersHistoryTotal(); 
        
            if(OrderSelect(hstTotal-1,SELECT_BY_POS,MODE_HISTORY))
            {
               if(OrderMagicNumber()==MagicNumber)
               {
                  tempo = OrderCloseTime();
                  if(OrderType()==OP_SELL )
                  {
                     if(OrderOpenPrice()>OrderClosePrice())  bool STOPTUDO = true;

                  }//FIM OP_SELL
               
                  if(OrderType()==OP_BUY   )
                  {
                     if(OrderOpenPrice()<OrderClosePrice())  bool STOPTUDOb = true;

                  }      
               }//FIM MAGICNUMBER
           }//FIM ORDERSELECT
           
        }//FIM ORDERHISTORY 
            
            int v, totalv=OrdersTotal();
            for(int i=OrdersTotal()-1; i>=0; i--)   
            {
               if(OrderSelect(v,SELECT_BY_POS)==true)
               {
                 
                 if( STOPTUDO==true || STOPTUDOb==true)  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                
                } 
           
            }//FIM CONTADOR  
             
  
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA ORDEM++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
    if(Time[0]>=tempo+1000)
   {
      if(OrdersTotal()==0)
      { 
        if(MAclose>MAmedia && MAopen>MAmedia && Open[1]>Open[2] && Open[2]>Open[3] ) ticket = OrderSend(Symbol(),OP_BUY,iLots,Ask,0,0,Ask+TAKE*MyPoint,Robo,MagicNumber,0,Blue);
        if(MAclose<MAmedia && MAopen<MAmedia && Close[1]<Close[2] && Close[2]<Close[3]) ticket = OrderSend(Symbol(),OP_SELL,iLots,Bid,0,0,Bid-TAKE*MyPoint,Robo,MagicNumber,0,Red);
        
      }//FIM ORDERSTOTAL
    }//FIM TIME
            
   for (int trade=OrdersTotal()-1; trade>=0; trade--) 
   {
      if (OrderSelect(trade,SELECT_BY_POS, MODE_TRADES)) 
      {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
         {
            
            if(OrderType()==OP_SELL)
            {
                if(Bid-STOP*MyPoint>OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_SELL,iLots,Bid,0,0,Bid-(TAKE+NumOfTrades)*MyPoint,NULL,MagicNumber,0,Red);
               break; 
            }//FIM OP_SELL
            
            if(OrderType()==OP_BUY)
            {
              if(Ask+STOP*MyPoint<OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_BUY,iLots,Ask,0,0,Ask+(TAKE+NumOfTrades)*MyPoint,NULL,MagicNumber,0,Blue);
               break;
           }//FIM OP_BUY
                 
         }//FIM MAGICNUMBER 
      }//FIM ORDERSELECT     
   }//FIM CONTADOR

  



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
