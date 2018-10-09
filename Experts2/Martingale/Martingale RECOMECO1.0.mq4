//VARIAS ORDENS
string Robo = "Martingale RECOMECO 1.0";
extern int Slippage = 0;
extern int MagicNumber1 = 121212;
extern int MagicNumber2 = 131313;

extern int TAKE = 5;
extern int STOP = 3;

extern double Lots = 0.03;

double Spread=MarketInfo(Symbol(),MODE_SPREAD);


int ticket,NumOfTrades,NumOfTrades2,ss,bb;
datetime tempo,tempo2;
double iLots,iLots2;

int OnInit(){return(INIT_SUCCEEDED);}
  
void OnTick()
  {     

//=========================POINT
      double MyPoint=Point;                                      
      if(Digits==3 || Digits==5) MyPoint=Point*10;               
      
//=========================MEDIAS MOVEIS
      double MAopen = iMA(Symbol(),NULL,9,0,MODE_EMA,PRICE_OPEN,0);
      double MAclose = iMA(Symbol(),NULL,9,0,MODE_EMA,PRICE_CLOSE,0); //12 legal.
      
//=========================LOTES
      iLots = Lots+(NumOfTrades*0.01); 
      iLots2 = Lots+(NumOfTrades2*0.01);

//=========================CONTADORES
      NumOfTrades = CountTrades();
      NumOfTrades2 = CountTrades2();
      ss = CountShell();
      bb = CountBuy();      
      
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++FECHAR TODAS ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
   
         static int closedOrders=0;
         if(OrdersHistoryTotal()!=closedOrders)
         {
            closedOrders=OrdersHistoryTotal();
            int hstTotal = OrdersHistoryTotal(); 
        
            if(OrderSelect(hstTotal-1,SELECT_BY_POS,MODE_HISTORY))
            {
               if(OrderMagicNumber()==MagicNumber1)
               {
                  tempo = OrderCloseTime();
                  if(OrderType()==OP_SELL )
                  {
                     if(OrderOpenPrice()>OrderClosePrice())  bool STOPTUDO = true;
                
                  }//FIM OP_SELL
               
                  if(OrderType()==OP_BUY   )
                  {
                     if(OrderOpenPrice()<OrderClosePrice()) bool STOPTUDOb = true;

                  }      
               }//FIM MAGICNUMBER
               
               if(OrderMagicNumber()==MagicNumber2)
               {
                  tempo2 = OrderCloseTime();
                  if(OrderType()==OP_SELL )
                  {
                     if(OrderOpenPrice()>OrderClosePrice()) bool STOPTUDO2 = true;

                  }//FIM OP_SELL
               
                  if(OrderType()==OP_BUY   )
                  {
                     if(OrderOpenPrice()<OrderClosePrice()) bool STOPTUDOb2 = true;
                     
                  }      
               }//FIM MAGICNUMBER
              
               
               
               
               
           }//FIM ORDERSELECT
           
        }//FIM ORDERHISTORY 
            
            int v, totalv=OrdersTotal();
            for(int i=OrdersTotal()-1; i>=0; i--)   
            {
               if(OrderSelect(v,SELECT_BY_POS)==true)
               {
                if(OrderMagicNumber()==MagicNumber1) if( STOPTUDO==true || STOPTUDOb==true)  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                if(OrderMagicNumber()==MagicNumber2) if( STOPTUDO2==true || STOPTUDOb2==true)  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);

               
                } 
           
            }//FIM CONTADOR  
               
  
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA ORDEM DE GATILHO++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
    if(Time[0]>=tempo+1000)
   {
      if(NumOfTrades==0)
      {
         if(MAclose>MAopen) ticket = OrderSend(Symbol(),OP_BUY,iLots,Ask,0,0,Ask+TAKE*MyPoint,Robo,MagicNumber1,0,Blue);
         if(MAopen>MAclose) ticket = OrderSend(Symbol(),OP_SELL,iLots,Bid,0,0,Bid-TAKE*MyPoint,Robo,MagicNumber1,0,Red);
        
      }//FIM ORDERSTOTAL
    }//FIM TIME
    
    if(Time[0]>=tempo2+2000)
    {
      if(NumOfTrades>=7 && NumOfTrades2==0)
      {
          if(MAclose>MAopen && ss>=1) ticket = OrderSend(Symbol(),OP_BUY,iLots2,Ask,0,0,Ask+TAKE*MyPoint,Robo,MagicNumber2,0,Blue);
          if(MAopen>MAclose  && bb>=1) ticket = OrderSend(Symbol(),OP_SELL,iLots2,Bid,0,0,Bid-TAKE*MyPoint,Robo,MagicNumber2,0,Red);
         
      }
    }  

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA DA SEGUNDA ORDEM MARTINGALE++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
         
   for (int trade=OrdersTotal()-1; trade>=0; trade--) 
   {
      if (OrderSelect(trade,SELECT_BY_POS, MODE_TRADES)) 
      {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber1)
         {
            
            if(OrderType()==OP_SELL)
            {
                if(Bid-STOP*MyPoint>OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_SELL,iLots,Bid,0,0,Bid-(TAKE+NumOfTrades)*MyPoint,NULL,MagicNumber1,0,Red);
               break; 
            }//FIM OP_SELL
            
            if(OrderType()==OP_BUY)
            {
              if(Ask+STOP*MyPoint<OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_BUY,iLots,Ask,0,0,Ask+(TAKE+NumOfTrades)*MyPoint,NULL,MagicNumber1,0,Blue);
               break;
           }//FIM OP_BUY
         }//FIM MAGICNUMBER 
         
         
         
         //INICIO MAGIC2
          if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber2)
          {
            
            if(OrderType()==OP_SELL)
            {
                if(Bid-STOP*MyPoint>OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_SELL,iLots2,Bid,0,0,Bid-(TAKE+NumOfTrades2)*MyPoint,NULL,MagicNumber2,0,Red);
               break; 
            }//FIM OP_SELL
            
            if(OrderType()==OP_BUY)
            {
              if(Ask+STOP*MyPoint<OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_BUY,iLots2,Ask,0,0,Ask+(TAKE+NumOfTrades2)*MyPoint,NULL,MagicNumber2,0,Blue);
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
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber1) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber1)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) count++;
   }
   return (count);
}

//Contar quantas ordens existe em aberto no Magic2
  
   int CountTrades2() {
   int count2 = 0;
   for (int trade2 = OrdersTotal() - 1; trade2 >= 0; trade2--) 
   {
      int a2 = OrderSelect(trade2, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber2) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber2)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) count2++;
   }
   return (count2);
}











int CountShell() {
   int countshell = 0;
   for (int trade4 = OrdersTotal() - 1; trade4 >= 0; trade4--) 
   {
      int a = OrderSelect(trade4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber1) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber1)
         if (OrderType() == OP_SELL) countshell++;

   }
   return (countshell);
   }
   
 int CountBuy() {
   int countbuy = 0;
   for (int trade3 = OrdersTotal() - 1; trade3 >= 0; trade3--) 
   {
      int a2 = OrderSelect(trade3, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber1) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber1)
         if (OrderType() == OP_BUY) countbuy++;

   }
   return (countbuy);
   }  
