

/*=======================================================ANOTAÇÕES========================================================

EA BREXIT.


 1 OPÇÃO DE EA)
   
   Abertura do gatilho, enquanto a vela fosse de >30PIPS enviaria ordem e esperaria TP ou SL pra enviar outra ordem.
   
   
 2 OPÇÃO DE EA)
   
   Abertura do gatilho, o preço seguindo para TP abriria mais uma ordem infinitamente até atingir SL. 

   
========================================================================================================================*/


extern int Slippage = 3;
extern int MagicNumber = 9090909; 

extern int StopLoss = 10;
extern int TakeProfit = 10;
extern int PipsCandle = 10;
extern int DistancieOrder = 5;
extern double Lots = 0.02;


int iLots;

string Robo = "Brexit 1.0";
int ticket;




int OnInit(){return(INIT_SUCCEEDED);}

void OnTick()
{        
 

//=========================POINT
      double MyPoint=Point;                                      
      if(Digits==3 || Digits==5) MyPoint=Point*10;   
 

int count,countbuy,countsell;
   
   for (int trade1=OrdersTotal()-1; trade1>=0; trade1--) 
   {
      if (OrderSelect(trade1,SELECT_BY_POS, MODE_TRADES)) 
      {  
         if(OrderMagicNumber()==MagicNumber)
         {
            if (OrderType() == OP_SELL || OrderType() == OP_BUY) count++;
            if(OrderType()==OP_BUY) countbuy++;
            if(OrderType()==OP_SELL) countsell++;
         }   
    
     }
   }
                     
switch(count) 
   {
      case 0: iLots = Lots; break;
      case 1: iLots = 0.03; break;
      case 2: iLots = 0.04; break;
      case 3: iLots = 1.0; break;
      case 4: iLots = 2.0; break;
      case 5: iLots = 3.0; break;
      case 6: iLots = 4.0; break;
      case 7: iLots = 5.0; break;
      case 8: iLots = 6.0; break;
      case 9: iLots = 7.0; break;
      case 10: iLots = 8.0; break;
   }
      if(count>=10) iLots = count*1.0;

                   
//++++++++++++++++++++++++++++++++++++++++++++++++++++ENCERRAR TODAS AS ORDENS+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 


         static int closedOrders=0;
         if(OrdersHistoryTotal()!=closedOrders)
         {
            closedOrders=OrdersHistoryTotal();
            int hstTotal = OrdersHistoryTotal(); 
        
            if(OrderSelect(hstTotal-1,SELECT_BY_POS,MODE_HISTORY))
            {
               if(OrderMagicNumber()==MagicNumber)
               {  
                  if(OrderType()==OP_BUY)
                  {
                     if(OrderOpenPrice()>OrderClosePrice()) bool STOPTUDOb = true; 
                    
                  }//FIM OP_BUY
                  
                  if(OrderType()==OP_SELL)
                  { 
                     if(OrderOpenPrice()<OrderClosePrice()) bool STOPTUDO2 = true;
                     
                  }//FIM OP_SELL
                     
               }//FIM MAGICNUMBER 
               
              
                
           }//FIM ORDERSELECT
        }//FIM ORDERHISTORY 
            
          
            for(int i=OrdersTotal()-1; i>=0; i--)   
            {
               if(OrderSelect(i,SELECT_BY_POS)==true)
               {
                  if(OrderMagicNumber()==MagicNumber)
                  {  
                     if(OrderType()==OP_BUY)
                     {
                        if(STOPTUDOb==true)  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                     }   
                     
                     if(OrderType()==OP_SELL )
                     {
                     
                      if(STOPTUDO2==true)  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink); 
                      
                     }
                  
                  }//FIM ORDERMAGIC
                  
                 
  
                }//FIM SELECT 
           
            }//FIM CONTADOR  
//=========================GATILHO PARA PRIMEIRA ORDEM.
      if(OrdersTotal()==0)
      { 
         if(Ask-PipsCandle*MyPoint>Open[0])    ticket= OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,0,0,Robo,MagicNumber,0,Blue);
         
      }    
      
//=========================MARTINGALE INVERSO
             for(int i9=OrdersTotal()-1; i9>=0; i9--)   
             {
               if(OrderSelect(i9,SELECT_BY_POS)==true)
               {
                  if(OrderMagicNumber()==MagicNumber)
                  {  
                     if(OrderType()==OP_BUY)
                     {//inves de STOP será de take!
                        
                        if(OrderClosePrice()-DistancieOrder*MyPoint>OrderOpenPrice()) ticket= OrderSend(Symbol(),OP_BUY,iLots,Ask,Slippage,Ask-10*MyPoint,0,Robo,MagicNumber,0,clrGreen); break; 
                        
                                                                                 
                     } //FIM OP_BUY 
                  }
               }

            }







               
  }//FIM ONTICK
 