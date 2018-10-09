/*========DESCRIÇÃO Clone IGUAL======



=======================*/


/*=======================================================ANOTAÇÕES========================================================
Sobre fechar todas as ordens invez de colocar variaveis globais coloquei locais.

As operaçoes sao encerradas ok! porém a ordem magic2 não. saber o pq.

tou quase la.

========================================================================================================================*/
input int MagicNumber1=1001; 
input int MagicNumber2=1002;
input int MagicNumber3=1003;
input int MagicNumber4=1004;

input double Lots1=0.01;
input double Lots2=0.02;
input double Lots3=0.08;
input double Lots4=0.40;

input int oneTP = 40; //80       //COMENTS. GRAFICO 1H. 30DIAS. RESULTADO BOM!.
 
input int twooSP = 20; //40
input int twooTP = 20; //40

input int threeSP = 15;
input int threeTP = 10;

input int fourSP = 10;
input int fourTP = 6;


int ticket,cc;


int OnInit(){return(INIT_SUCCEEDED);}
void OnDeinit(const int reason){}


void OnTick()
  {
//---
 


              //=================POINT=====================================
               double MyPoint=Point;                                      
               if(Digits==3 || Digits==5) MyPoint=Point*10;               
             //============================================================
                    
                
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA MAGIC1++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

      if(OrdersTotal()==0)
      { 
      
      
         ticket   =      OrderSend(Symbol(),OP_BUY,Lots1,Ask,0,0,Ask+oneTP*MyPoint,NULL,MagicNumber1,0,Blue);      
         ticket   =      OrderSend(Symbol(),OP_SELL,Lots1,Bid,0,0,Bid-oneTP*MyPoint,NULL,MagicNumber1,0,Red);
      }

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA MAGIC2++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

         if(OrdersTotal()==1)
         {
            int cnt, total=OrdersTotal();
            for(cnt=0;cnt<total;cnt++)
            {
               if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
               if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber1)
               {
      
                  if(OrderType()==OP_SELL)
                  {  
                     bool SEND2shell = OrderSend(Symbol(),OP_SELL,Lots2,Bid,0,0,0,NULL,MagicNumber2,0,clrPink);      
                  }//FIM OP_SELL   
         
                  if(OrderType()==OP_BUY)
                  {
                     bool SEND2buy = OrderSend(Symbol(),OP_BUY,Lots2,Ask,0,0,0,NULL,MagicNumber2,0,clrPink);
                  }//FIM OP_BUY
                  
               }//FIM OrderMagicNumber        
        
             }//Fim Contador
          }//FIM IF 
          
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++STOP E TAKE MAGIC2++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++     
      
      int j, totalj=OrdersTotal();
      for(j=0;j<totalj;j++)
      {
         if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber2)
         {
            if(OrderType()==OP_SELL)
            {     
              if(Bid+twooTP*MyPoint<OrderOpenPrice()) bool TAKE2shell =  OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
         
              if(Bid-twooSP*MyPoint>OrderOpenPrice())  bool STOP2shell=true;
              
            }//FIM OP_SELL
            
            if(OrderType()==OP_BUY)
            {
               if(Ask-twooTP*MyPoint>OrderOpenPrice()) bool TAKE2buy = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink); 
               
               if(Ask+twooSP*MyPoint<OrderOpenPrice()) bool STOP2buy=true;
                
            }//FIM OP_BUY
               
         }//FIM MAGIC
      }//FIM CONTADOR            
  
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA MAGIC3++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++       
         
         if(OrdersTotal()==2)
         {
            int d, totald=OrdersTotal();
            for(d=0;d<totald;d++)
            {
               if(OrderSelect(d,SELECT_BY_POS,MODE_TRADES))
               if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber2)
               {
                  if(OrderType()==OP_SELL)
                  {
                    if(STOP2shell==true) bool SEND3shell = OrderSend(Symbol(),OP_SELL,Lots3,Bid,0,0,0,NULL,MagicNumber3,0,clrPink);
                  }
               
                  if(OrderType()==OP_BUY)
                  {
                     if(STOP2buy==true) bool SEND3buy = OrderSend(Symbol(),OP_BUY,Lots3,Ask,0,0,0,NULL,MagicNumber3,0,clrPink);
                  }     
                  
                  
                 
               }//FIM MAGIC
            }//FIM CONTADOR
        }//FIM ORDERS.
               
                  
                    
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++STOP E TAKE MAGIC3++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++     
      
      int k, totalk=OrdersTotal();
      for(k=0;k<totalk;k++)
      {
         if(OrderSelect(k,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber3)
         {
            if(OrderType()==OP_SELL)
            { 
               if(Bid+threeTP*MyPoint<OrderOpenPrice()) bool TAKE3shell = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
           
               if(Bid-threeSP*MyPoint>OrderOpenPrice()) bool STOP3shell=true;
                
             }//FIM OP_SELL   
             
            if(OrderType()==OP_BUY)
            {
               if(Ask-threeTP*MyPoint>OrderOpenPrice()) bool TAKE3buy = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
               if(Ask+threeSP*MyPoint<OrderOpenPrice()) bool STOP3buy = true;
               
            }    
         
         }//FIM MAGIC
     
     }//FIM CONTADOR  
          
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++Abertura MAGIC4++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++             
    
     if(OrdersTotal()==3  )
     {
      int h, totalh=OrdersTotal();
      for(h=0;h<totalh;h++)
      {
         if(OrderSelect(h,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber3)
         {
            if(OrderType()==OP_SELL)
            {
              if(STOP3shell ==true) bool SEND4buy =  OrderSend(Symbol(),OP_BUY,Lots4,Ask,0,0,0,NULL,MagicNumber4,0,clrPink);   
            }//FIM OP_SELL
            
            if(OrderType()==OP_BUY)
            {
              if(STOP3buy==true) bool SEND4shell= OrderSend(Symbol(),OP_SELL,Lots4,Bid,0,0,0,NULL,MagicNumber4,0,clrPink);
            }//FIM OP_BUY
            
         }//FIM MAGIC
         }//FIM CONTADOR             
          }//FIM ORDERSTOTAL
         
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++STOP E TAKE MAGIC4++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++     
      
      int b, totalb=OrdersTotal();
      for(b=0;b<totalb;b++)
      {
         if(OrderSelect(b,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber4)
         {
            if(OrderType()==OP_BUY)
            {  
               if(Ask-fourTP*MyPoint>OrderOpenPrice()) bool TAKE4buy= OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
            }//FIM OP_BUY
           
           if(OrderType()==OP_SELL)
           {
             if(Bid+fourTP*MyPoint<OrderOpenPrice()) bool TAKE4shell= OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
           }//FIM OP_SELL 
           
         }//FIM MAGIC
      }//FIM CONTADOR.         
                        
               
                   
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++FECHAMENTO DE TODAS AS ORDENS++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++                     
                          
            int v, totalv=OrdersTotal();
            for(v=0;v<totalv;v++)
            {
               if(OrderSelect(v,SELECT_BY_POS,MODE_TRADES))
               {
                 if(TAKE2buy==true || TAKE2shell==true || TAKE3shell==true || TAKE3buy==true || TAKE4buy==true || TAKE4shell==true) ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
               }
           
            }//FIM CONTADOR                
                   
   
   //POR ALGUM MOTIVO A ORDEM2 SO FECHA ABRINDO OUTRO CONTADOR.                
            int vx, totalvx=OrdersTotal();
            for(vx=0;vx<totalvx;vx++)
            {
               if(OrderSelect(vx,SELECT_BY_POS,MODE_TRADES))
               {
                  if(OrderMagicNumber()==MagicNumber2)
                  {
                     if(TAKE2buy==true || TAKE2shell==true || TAKE3shell==true || TAKE3buy==true || TAKE4buy==true || TAKE4shell==true) ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                  }
           }
            }//FIM CONTADOR                       }

        
   }//FIM OnTick()
//+------------------------------------------------------------------+

