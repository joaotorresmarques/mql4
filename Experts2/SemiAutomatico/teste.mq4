

/*=======================================================ANOTAÇÕES========================================================
terminado. testar no VPN


========================================================================================================================*/


static input string Option1 = "------- Configurações Basicas";

extern int MagicNumber = 7676777; 
extern int StopLoss = 10;

static input string Option2 = "--------Configurações TrallingStop";

extern int TrallingStop =20;
extern int RetirarPips = 6;
extern int TrallingStep = 20;
extern int RetirarStep =5;

static input string Option4 = "--------Outras Opções";
extern int MinuteFinish = 80; //encerrar ordem pendente


string Robo = "SemiAutomatico";
int ticket;

bool Order2,countsellFINISH,countbuyFINISH;


int OnInit(){return(INIT_SUCCEEDED);}

void OnTick()
{        
  
      
for (int trade3=OrdersTotal()-1; trade3>=0; trade3--) 
    {
      if (OrderSelect(trade3,SELECT_BY_POS, MODE_TRADES)) 
      {
          
                if(OrderType()==OP_BUY)
               {
                  double stnewpricebuy = OrderOpenPrice();
                  double SL = OrderStopLoss();
              
                  if(SL==0) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-100,0,0,clrLightGreen);
               
               }
               }
               }   
  
  
               
  }//FIM ONTICK
 