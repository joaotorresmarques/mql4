/*========DESCRIÇÃO Martingale 1.0======   
=======================*/

/*=======================================================ANOTAÇÕES========================================================
*So funciona no USDJPY se excluir o *Point.

ESTUDO DE HOJE:
   
   -VERIFICAR SE O CALCULO (SPREAD+TAKE) ESTA DANDO CERTO.
   -TIRAR O *POINT OQ ACONTECE?
   -COLOCAR EM CONTA DEMO HOJE!
   -BACKTEST EM VARIAS MOEDAS
   
*Tenho que verificar se eu sou stopado por falta de margem com esse robo. porque se nao, colocar em 2 moedas quando for pra conta real!   
   


========================================================================================================================*/

string Robo = "Martingale PREMIUM";
extern int Slippage = 3;
extern int MagicNumber = 121212;
extern int MagicNumber2 = 131313;

extern int TAKE = 10;
extern int STOP = 5;

extern double Lots = 0.01; //0.01 é muito arriscado. ja perco 0,32cents.


double Spread=MarketInfo(Symbol(),MODE_SPREAD);
int ticket,NumOfTrades,ss,bb,am;
datetime tempo;
double iLots;

int OnInit(){return(INIT_SUCCEEDED);}
  
void OnTick()
  {     

            
//=========================POINT
      double MyPoint=Point;                                      
      if(Digits==3 || Digits==5) MyPoint=Point*10;               
      
//=========================MEDIAS MOVEIS
       
      double MAlenta = iMA(Symbol(),NULL,4,0,MODE_EMA,PRICE_CLOSE,0);
      double MArapida = iMA(Symbol(),NULL,21,0,MODE_EMA,PRICE_CLOSE,0); 
     
//=========================LOTES
      NumOfTrades = CountTrades();
      iLots = Lots+(NumOfTrades*0.01); //0.01 ou 0.02? verificar em DEMO qual da 1cent de lucro
      
      ss = CountShell();
      bb = CountBuy();
      
      am = CountTrades5();
      
      
   
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA ORDEM++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
   if(Time[0]>=tempo)
   {
      if(NumOfTrades==0)
      {
       
         if(MAlenta>MArapida) ticket = OrderSend(Symbol(),OP_SELL,0.1,Bid,0,0,Bid-TAKE*MyPoint,Robo,MagicNumber,0,Red);
         if(MAlenta<MArapida) ticket = OrderSend(Symbol(),OP_BUY,0.1,Ask,0,0,Ask+TAKE*MyPoint,Robo,MagicNumber,0,Blue);
          
      }
     
     if(ss==0 && am==0 && NumOfTrades>=1)
     {
      if(MAlenta>MArapida) ticket = OrderSend(Symbol(),OP_SELL,iLots,Bid,0,0,Bid-TAKE*MyPoint,Robo,MagicNumber2,0,Red);
     }
     
     if(bb==0 && am==0 && NumOfTrades>=1)
     {
       if(MAlenta<MArapida) ticket = OrderSend(Symbol(),OP_BUY,iLots,Ask,0,0,Ask+TAKE*MyPoint,Robo,MagicNumber2,0,Blue);
     }
     
    
    
    
  }
 
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ENVIO DE ORDEM MARTINGALE++++++++++++++++++++++++++++++++++++++++++++++++++++++++             
   for (int trade=OrdersTotal()-1; trade>=0; trade--) 
   {
      if (OrderSelect(trade,SELECT_BY_POS, MODE_TRADES)) 
      {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
         {
            
            if(OrderType()==OP_SELL)
            {
               if(Bid-STOP*MyPoint>OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_SELL,iLots,Bid,0,0,(Bid-NumOfTrades*MyPoint),Robo,MagicNumber,0,Red);
               break; 
            }
            
            if(OrderType()==OP_BUY)
            {
               if(Ask+STOP*MyPoint<OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_BUY,iLots,Ask,0,0,(Ask+NumOfTrades*MyPoint),Robo,MagicNumber,0,Blue);
               break;
           }//FIM OP_BUY  
             
         }//FIM MAGICNUMBER
         
         
         
      }//FIM ORDERSELECT   
   }//FIM CONTADOR
       
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++FECHAR TODAS ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
   
      
         static int closedOrders=0;
         if(OrdersHistoryTotal()!=closedOrders)
         {
            closedOrders=OrdersHistoryTotal();
            int hstTotal = OrdersHistoryTotal(); 
        
            if(OrderSelect(hstTotal-1,SELECT_BY_POS,MODE_HISTORY))
            {
               tempo = OrderCloseTime();
               if(OrderType()==OP_SELL && OrderMagicNumber()==MagicNumber  )
               {
                  if(OrderOpenPrice()>OrderClosePrice())
                  {
                     bool STOPTUDO = true;
                  }
               }//FIM OP_SELL
               
               if(OrderType()==OP_BUY && OrderMagicNumber()==MagicNumber  )
               {
                  if(OrderOpenPrice()<OrderClosePrice())
                  {
                     bool STOPTUDOb = true;
                  }
               }//FIM OP_BUY      
               
               
              
               
               
           }
        } 
            
            int v, totalv=OrdersTotal();
            for(int i=OrdersTotal()-1; i>=0; i--)   
            {
               if(OrderSelect(v,SELECT_BY_POS)==true)
               {
                  if( OrderMagicNumber()==MagicNumber)
                  {
               
                 
                 if( STOPTUDO==true || STOPTUDOb==true)  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                }
                
                
                
                } 
           
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

 int CountTrades5() {
   int count5 = 0;
   for (int trade5 = OrdersTotal() - 1; trade5 >= 0; trade5--) 
   {
      int a = OrderSelect(trade5, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber2) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber2)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) count5++;

   }
   return (count5);
}





 int CountShell() {
   int countshell = 0;
   for (int trade2 = OrdersTotal() - 1; trade2 >= 0; trade2--) 
   {
      int a = OrderSelect(trade2, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         if (OrderType() == OP_SELL) countshell++;

   }
   return (countshell);
   }
   
 int CountBuy() {
   int countbuy = 0;
   for (int trade3 = OrdersTotal() - 1; trade3 >= 0; trade3--) 
   {
      int a2 = OrderSelect(trade3, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         if (OrderType() == OP_BUY) countbuy++;

   }
   return (countbuy);
   }  
