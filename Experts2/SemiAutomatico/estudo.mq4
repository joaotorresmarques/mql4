
/*=======================================================ANOTAÇÕES========================================================
Realizar TODOS OS TESTES no demo.
quando tiver absoluta certeza lançar na conta real. acredito que so segunda.
QUINTA TEM BREXIT.


========================================================================================================================*/


static input string Option1 = "------- Configurações Basicas";
extern int StopLoss = 10;

static input string Option2 = "--------Configurações TrallingStop";
extern int TrallingStop =20;
extern int RetirarPips = 6;


static input string Option4 = "--------Outras Opções";
extern int MinuteFinish = 80; //encerrar ordem pendente


string Robo = "SemiAutomatico";
int ticket;
double Spread = MarketInfo(Symbol(),MODE_SPREAD);

bool Order2,countsellFINISH,countbuyFINISH;

int OnInit(){return(INIT_SUCCEEDED);}

void OnTick()
{        

  Comment(  "\n\n",
            "    Olá João, Operando com o Robo  ",Robo,"\n",
            "   ......................................................................","\n\n",
            
            "    Moeda           ","        ",Symbol(),"\n",
            "    Spread          ","        ",Spread,"\n\n",
            
            "   ......................................................................","\n\n",
            
           "     Valor Atual     ","         ",AccountBalance()," USD","\n\n",
           
           "    ......................................................................","\n\n"

           
           
           ); 
      
//=========================POINT
      double MyPoint=Point;                                      
      if(Digits==3 || Digits==5) MyPoint=Point*10;   
   
if(OrdersTotal()==0)
{
   ticket = OrderSend(Symbol(),OP_BUY,1.0,Ask,0,0,0,Robo,1,0,clrGreenYellow);
}   
               
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++TRALLING STOP+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
  
    for (int trade3=OrdersTotal()-1; trade3>=0; trade3--) 
    {
      if (OrderSelect(trade3,SELECT_BY_POS, MODE_TRADES)) 
      {
         if(OrderType()==OP_BUY)
         {
            double stnewpricebuy = OrderOpenPrice();
            double SL = OrderStopLoss();
              
            if(SL==0) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-StopLoss*MyPoint,0,0,clrLightGreen);
            if(SL>0 && (Bid>OrderStopLoss()+TrallingStop*MyPoint))   ticket = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss()+(TrallingStop-RetirarPips)*MyPoint,0,0,clrLightGreen);
               
         }//FIM OP_BUY  
   
         if(OrderType()==OP_SELL)
         { 
           double stnewpricesell = OrderOpenPrice();
           double SLsell = OrderStopLoss();
              
           if(SLsell==0) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+StopLoss*MyPoint,0,0,clrLightGreen);         
           if(SLsell>0 && (Ask<OrderStopLoss()-TrallingStop*MyPoint))  ticket = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss()-(TrallingStop-RetirarPips)*MyPoint,0,0,clrLightGreen);
         }//FIM OP_SELL
              
     }//FIM SELECT
   }//FIM CONTADOR  

  
               
  }//FIM ONTICK
 