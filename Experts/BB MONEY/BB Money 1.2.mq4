/*========DESCRIÇÃO BB Money 1.2====== 
  
=======================*/


/*=======================================================ANOTAÇÕES========================================================

========================================================================================================================*/
input int Slippage = 0;
input int MagicNumber1 = 8001;
input int MagicNumber2 = 8002;

input int Lots1 = 1.0;
input int Lots2 = 2.0;

input int TAKE1 = 20; 
input int TAKE2 = 10; 

input int STOP1 = 20; 
input int STOP2 = 30; //Era 0, más corro um grande risco de zerar a banca.
int ticket;

void OnTick()
  {
      //========================POINT===============================
               double MyPoint=Point;                                      
               if(Digits==3 || Digits==5) MyPoint=Point*10;               
      //============================================================
      
     double BBupper = iBands(Symbol(),NULL,20,2,0,PRICE_CLOSE,MODE_UPPER,0); //antes era: 23,3.
     double BBlower = iBands(Symbol(),NULL,20,2,0,PRICE_CLOSE,MODE_LOWER,0);
     
      
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA ORDEM++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++       
   
   if(OrdersTotal()==0)
   { 
      if(Ask > BBupper || Bid > BBupper)
      {
         
        ticket = OrderSend(Symbol(),OP_BUY,Lots1,Ask,Slippage,0,Ask+TAKE1*MyPoint,NULL,MagicNumber1,0,Blue);
      }
      
      if(Bid < BBlower || Ask < BBlower)
      {
         ticket =  OrderSend(Symbol(),OP_SELL,Lots1,Bid,Slippage,0,Bid-TAKE1*MyPoint,NULL,MagicNumber1,0,Red);
      }      
  
  }//FIM ORDERSTOTAL
  
  
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++CONFIGURAÇÃO DE ORDEM MAGIC 1++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  
      if(OrdersTotal()==1   )
      {
      int cnt, total=OrdersTotal();
      for(cnt=0;cnt<total;cnt++)
      {
         if (OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==true)
         if(OrderSymbol()==Symbol()&&OrderMagicNumber()==MagicNumber1)
         {
            if(OrderType()==OP_BUY) 
            {  //DEFINIÇÃO DE STOP
               if(Ask+STOP1*MyPoint < OrderOpenPrice())
               { 
                  ticket =  OrderSend(Symbol(),OP_SELL,Lots2,Bid,Slippage,0,Bid-TAKE2*MyPoint,NULL,MagicNumber2,0,Red);
                     bool CLOSEMAGIC1BUY = true;
               }      
               
            }//FIM OP_BUY
            
            
            if(OrderType()==OP_SELL) 
            {  //DEFINIÇÃO DE STOP
               if(Bid-STOP1*MyPoint>OrderOpenPrice()) 
               { 
                  ticket = OrderSend(Symbol(),OP_BUY,Lots2,Ask,Slippage,0,Ask+TAKE2*MyPoint,NULL,MagicNumber2,0,Blue);
                  bool CLOSEMAGIC1SHELL = true;
               }   
            }//FIM OP_SELL      
            
            
         }//FIM ORDERMAGIC
      }//FIM CONTADOR      
      }      

               
         

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ENCERRAMENTO DE TODAS AS ORDENS++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
               
            int v, totalv=OrdersTotal();
            for(v=0;v<totalv;v++)
            {
               if(OrderSelect(v,SELECT_BY_POS,MODE_TRADES))
               {
                 if(CLOSEMAGIC1BUY==true || CLOSEMAGIC1SHELL==true ) ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                } 
           
            }//FIM CONTADOR     
            
  
  
  
  
  
  
  }//FIM ONTICK
