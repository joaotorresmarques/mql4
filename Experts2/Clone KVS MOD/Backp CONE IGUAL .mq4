/*========DESCRIÇÃO Clone IGUAL======



=======================*/


/*=======================================================ANOTAÇÕES========================================================


========================================================================================================================*/
input int MagicNumber1=1001; 
input int MagicNumber2=1002;
input int MagicNumber3=1003;
input int MagicNumber4=1004;
input double Lots1=1.0;
input double Lots2=2.0;
input double Lots3=3.0;
input double Lots4=4.0;

input int oneTP = 40;
 
input int twooSP = 20;
input int twooTP = 20;

input int threeSP = 15;
input int threeTP = 10;

input int fourSP = 10;
input int fourTP = 6;


int ticket,cc;
bool STOP2shell,STOP2buy;
bool STOP3shell,TAKE3shell,STOP4buy;
bool TAKE4buy=false;

int OnInit(){return(INIT_SUCCEEDED);}
void OnDeinit(const int reason){}


void OnTick()
  {
//---
 
Comment(TAKE4buy);

              //=================POINT=====================================
               double MyPoint=Point;
               if(Digits==3 || Digits==5) MyPoint=Point*10;
//=================POINT=====================================

            int v, totalv=OrdersTotal();
            for(v=0;v<totalv;v++)
            {
               if(OrderSelect(v,SELECT_BY_POS,MODE_TRADES))
               {
                  if(OrderType()==OP_SELL)
                  {
               
                     if(OrderMagicNumber()==MagicNumber1 || OrderMagicNumber()==MagicNumber2 || OrderMagicNumber()==MagicNumber3  )
                     {
                        if(TAKE4buy==true) ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                     }
                  }
                
                 
                  
                  
                   } 
                   } 
                    
                
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA MAGIC1++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

      
      if(OrdersTotal()==0 )
      { 
      
      
         ticket   =      OrderSend(Symbol(),OP_BUY,Lots1,Ask,0,0,Ask+oneTP*MyPoint,NULL,MagicNumber1,0,Blue);      
         ticket   =      OrderSend(Symbol(),OP_SELL,Lots1,Bid,0,0,Bid-oneTP*MyPoint,NULL,MagicNumber1,0,Red);
      }

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA MAGIC2++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
if (Is_There_Already_Opened_Position() == false)
   {
         if(OrdersTotal()==1  )
         {
            int cnt, total=OrdersTotal();
            for(cnt=0;cnt<total;cnt++)
            {
               if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
               if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber1)
               {
      
                  if(OrderType()==OP_SELL)
                  {  
                     ticket = OrderSend(Symbol(),OP_SELL,Lots2,Bid,0,0,0,NULL,MagicNumber2,0,clrPink);      
                  }//FIM OP_SELL   
         
                  if(OrderType()==OP_BUY)
                  {
                     ticket = OrderSend(Symbol(),OP_BUY,Lots2,Ask,0,0,0,NULL,MagicNumber2,0,clrPink);
                  }//FIM OP_BUY
                  
               }//FIM OrderMagicNumber        
        
             }//Fim Contador
          }//FIM IF 
          }
          

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
         
              if(Bid-twooSP*MyPoint>OrderOpenPrice())  STOP2shell=true;
              
              
            }//FIM OP_SELL
            
            if(OrderType()==OP_BUY)
            {
               if(Ask-twooTP*MyPoint>OrderOpenPrice()) bool TAKE2buy = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink); 
               
               if(Ask+twooSP*MyPoint<OrderOpenPrice()) STOP2buy=true;
                
            }//FIM OP_BUY
               
         }//FIM MAGIC
      }//FIM CONTADOR            
  
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA MAGIC3++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++       
         if (Is_There_Already_Opened_Position() == false)
   {
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
            }         
                  
                    
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++STOP E TAKE MAGIC3++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++     
      int k, totalk=OrdersTotal();
      for(k=0;k<totalk;k++)
      {
         if(OrderSelect(k,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber3)
         {
            if(OrderType()==OP_SELL)
            { 
               if(Bid+threeTP*MyPoint<OrderOpenPrice()) TAKE3shell = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
           
               if(Bid-threeSP*MyPoint>OrderOpenPrice()) STOP3shell=true;
                
             }//FIM OP_SELL   
             
            if(OrderType()==OP_BUY)
            {
            }    
         
         }//FIM MAGIC
     
     }//FIM CONTADOR  
          
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++Abertura MAGIC4++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++             
     if (Is_There_Already_Opened_Position() == false)
   {
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
               if(STOP3shell ==true) bool SEND4buy =  OrderSend(Symbol(),OP_SELL,Lots4,Bid,0,0,0,NULL,MagicNumber4,0,clrPink);
                  
                
            }
         }
         }             
          }
         }
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++STOP E TAKE MAGIC4++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++     
      
      int b, totalb=OrdersTotal();
      for(b=0;b<totalb;b++)
      {
         if(OrderSelect(b,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber4)
         {
            if(OrderType()==OP_SELL)
            {  
               
               if(Bid+threeTP*MyPoint<OrderOpenPrice()) TAKE4buy= OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
               
               
               
               //if(Ask-fourTP*MyPoint>OrderOpenPrice()) TAKE4buy= true; 
               //if(Ask+fourSP*MyPoint<OrderOpenPrice()) STOP4buy = true;
            }
         }
      }         
                        
               
                   
                   
                   
                   
                   
                   
                     
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ENCERRAR MAGIC1++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
         
  int r, totalr=OrdersTotal();
      for(r=0;r<totalr;r++)
      {
         if(OrderSelect(r,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber1)
         {
            if(OrderType()==OP_SELL)
            {
               if(TAKE2shell==true ) ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink); 
            }
            
            if(OrderType()==OP_BUY)
            {
               if(TAKE2buy==true  ) ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
               
            }
         }
     }   
                      
        
    
        
   }//FIM OnTick()
//+------------------------------------------------------------------+

bool Is_There_Already_Opened_Position() //True when there is open order, False when thre is no open order
   {
   int total = OrdersTotal();
   for(int i = 1; i <= total; i++)
      {
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true
          && OrderMagicNumber() == MagicNumber4 
          && OrderSymbol() == Symbol())
         {
          
          return (TAKE4buy=true);
         }
      }
  
   return (TAKE4buy=false);
   }