//2 number means a point (x,y),4 points(8 numbers) define a shape
    //-,L,J,Z,5,O,T
    var over=false,shapes=("0,1,1,1,2,1,3,1;1,0,1,1,1,2,2,2;2,0,2,1,2,2,1,2;0,1,1,1,1,2,2,2;1,2,2,2,2,1,3,1;1,1,2,1,1,2,2,2;0,2,1,2,1,1,2,2").split(";");
    
    var color=("#FF0000FF;#00FF00FF;#0000FFFF;#FFFF00FF;#FF00FFFF;#00FFFFFF;#FFFFFFFF").split(";");

    var fastdown = false;

    function create(type){//m:moving d:dead
        var temp_panel = $.CreatePanel( "Panel",$.GetContextPanel().GetChild(0).GetChild(0),"");
        // temp_panel.BLoadLayout( "file://{resources}/layout/custom_game/tetris.xml", false, false );
        if(type=="base"){
            temp_panel.style.width = "38px";
            temp_panel.style.height = "38px";
            temp_panel.style.backgroundColor = "#00000000";
        }else if(type=="next"){
            var temp_panel = $.CreatePanel( "Panel",$.GetContextPanel().GetChild(1),"");
            temp_panel.style.width = "38px";
            temp_panel.style.height = "38px";
            temp_panel.style.backgroundColor = "#00000000";
        }
        else if(type=="d"){
            //create empty panel
        }
        return temp_panel;
    }

    function Tetris(c, t, x, y){//c,shape,3,0var 
        var c=c?c:"d";

        //init 4 square
        this.divs = [create(c),create(c),create(c),create(c)];
        this.nextdives = [create(c),create(c),create(c),create(c)];

        var ran_ = Math.floor(Math.random()*(shapes.length-0.00001));

        this.reset = function(){
            //position of the moving shape
            this.x = typeof x != 'undefined'?x:3;//place the shape at horizontal middle
            this.y = typeof y != 'undefined'?y:0;

            var ran = Math.floor(Math.random()*(shapes.length-0.00001));
            
            this.shape = t?t:(this.nextshape?this.nextshape:shapes[ran_].split(","));//Math.random return range 0-1
            this.shapecolor = this.nextshapecolor?this.nextshapecolor:color[ran_];

            this.nextshape = shapes[ran].split(",");
            this.nextshapecolor = color[ran];

            // this.show();
            if(this.field&&this.field.check(this.shape,this.x,this.y,'v')=='D'){//check weather the game is over
                $.Msg("game over");
                over=true;
                this.field.fixShape(this.shape,this.x,this.y);
                GameEvents.SendCustomGameEventToServer( "tetris_failed", {} );
                resetAll();            
            } 
        } 

        this.show = function(){
            for(var i in this.nextdives){
                this.nextdives[i].style.backgroundColor = "#00000000";
            }
            for(var i in this.nextdives){
                this.field.nextfield[this.nextshape[i*2]*1+(this.nextshape[i*2+1]*1)*this.field.nextwidth].style.backgroundColor = this.nextshapecolor
                this.nextdives[i]=this.field.nextfield[this.nextshape[i*2]*1+(this.nextshape[i*2+1]*1)*this.field.nextwidth];
            }

            for(var i in this.divs){
                if(!this.divs[i].occupied)
                this.divs[i].style.backgroundColor = "#00000000";
            }
            for(var i in this.divs){
                //place squares

                //add for new construction

                // this.divs[i].style.left = (this.shape[i*2]*1+this.x)*20+'px';
                // this.divs[i].style.top = (this.shape[i*2+1]*1+this.y)*20+'px';
                this.field[(this.shape[i*2]*1+this.x) + (this.shape[i*2+1]*1+this.y)*this.field.width].style.backgroundColor = this.shapecolor
                this.divs[i] = this.field[(this.shape[i*2]*1+this.x) + (this.shape[i*2+1]*1+this.y)*this.field.width];
            }
        }//*1 trans string to int

        this.field=null;
        this.hMove = function(step){
            var r = this.field.check(this.shape,this.x- -step,this.y,'h');
            if(r!='N'&&r==0){
                this.x-=(-step);
                this.show();}}

        this.vMove = function(){
            if(this.field.check(this.shape,this.x,this.y- -1,'v')=='N'){
                this.y++;
                this.show();}
            else{
                $.Msg("new one");
                fastdown = false;
                this.field.fixShape(this.shape,this.x,this.y);
                this.field.findFull();
                this.reset();}}

        this.rotate = function(){
            var s=this.shape;
            var newShape=[3-s[1],s[0],3-s[3],s[2],3-s[5],s[4],3-s[7],s[6]];
            var r = this.field.check(newShape,this.x,this.y,'h');
            if(r=='D')return;
            if(r==0){
                this.shape=newShape;
                this.show();}
            else if(this.field.check(newShape,this.x-r,this.y,'h')==0){
                this.x-=r;
                this.shape=newShape;
                this.show();}}

        this.falldown = function(){
            fastdown = true;
            for(;fastdown;){
                this.vMove();
            }
        }
         $.Msg("reset");
        this.reset();}

    function Field(w,h){
        //background width&height
        this.width = w?w:10;
        this.height = h?h:20;

        this.nextwidth = 4;
        this.nextheight = 4;
        this.nextfield = new Array();
        this.show = function(){
            //add for new construction

            // var f = create("div","f")
            // f.style.width=this.width*20+'px';
            // f.style.height=this.height*20+'px';

            //next zone
            for(var h=0;h<this.nextheight;h++){
                for(var w=0;w<this.nextwidth;w++){
                    var div = create("next");
                    div.style.marginLeft = w*40 + 'px';
                    div.style.marginTop = h*40 + 'px';
                    this.nextfield[w+h*this.nextwidth] = div;
                }
            }

            //game zone
            for(var h=0;h<this.height;h++){
                for(var w=0;w<this.width;w++){
                    var div = create("base");
                    div.style.marginLeft = w*40 + 'px';
                    div.style.marginTop = h*40 + 'px';
                    this[w+h*this.width] = div;
                }
            }
        }
        
        //add for restart game
        this.reset = function(){
            for(var h=0;h<this.height;h++){
                for(var w=0;w<this.width;w++){
                    this[w+h*this.width].occupied = false;
                    this[w+h*this.width].style.backgroundColor = "#00000000";
                }
            }
        }

        this.findFull = function(){
            //l means the line number to remove
            var count = 0;
            for(var l=0;l<this.height;l++){
                var s=0;
                for(var i=0;i<this.width;i++){
                    s+=this[l*this.width+i].occupied?1:0;}
                if(s==this.width){
                    this.removeLine(l);
                    count++;
                }
            }
            if(count>0){
                Game.EmitSound("Tutorial.TaskProgress");
                GameEvents.SendCustomGameEventToServer( "remove_line", {  count : count} );
            }else{
                Game.EmitSound( "ui_team_select_pick_team" );
            }
            //add gold accourding to the number of line removed at once
        }

        this.removeLine = function(line){
            //remove the filled line
            for(var i=0;i<this.width;i++){
                // document.body.removeChild(this[line*this.width+i]);
                //may a better way to remove
                this[line*this.width+i].style.backgroundColor = "#00000000";
                this[line*this.width+i].occupied = false;
            }

            //move left squares down
            for(var l=line;l>0;l--){
                for(var i=0;i<this.width;i++){
                    this[l*this.width- -i].occupied=this[(l-1)*this.width- -i].occupied;
                    //move down the lines before the remove one
                    if(this[l*this.width- -i].occupied){
                        //have problem about this 
                        // this[l*this.width- -i].style.top = l*20+'px';
                        this[l*this.width- -i].style.backgroundColor = "#333333FF";
                    }else{
                        this[l*this.width- -i].style.backgroundColor = "#00000000";
                    }
                }
            }
        }

        this.check = function(shape, x, y, d){
            var r1=0,r2='N';
            for(var i=0;i<8;i+=2){
                if(shape[i]- -x < 0 && shape[i]- -x <r1)
                    {r1 = shape[i]- -x;}
                else if(shape[i]- -x>=this.width && shape[i]- -x>r1)
                    {r1 = shape[i]- -x;}
                if(shape[i+1]- -y>=this.height || this[shape[i]- -x- -(shape[i+1]- -y)*this.width].occupied)
                    {r2='D'}}
            if(d=='h'&&r2=='N')return r1>0?r1-this.width- -1:r1;
            else return r2;}

        //create a dead shape at the bottom
        this.fixShape = function(shape,x,y){
            //add for new construction

            // var d=new Tetris("d",shape,x,y);
            // d.show();
            for(var i=0;i<8;i+=2){
                //this[x],x is background box number left to right,up to down,0-9 0-19
                // this[shape[i]- -x- -(shape[i+1]- -y)*this.width]=d.divs[i/2];
                this[shape[i]- -x- -(shape[i+1]- -y)*this.width].style.backgroundColor = "#333333FF";
                this[shape[i]- -x- -(shape[i+1]- -y)*this.width].occupied = true;
            }
        }
    }
    var f = new Field();
    f.show();
    var s = new Tetris();
    s.field = f;
    s.show();
    // Tstart(); 

    function resetAll(){
        s.field.reset();
        s.reset();
        over=false;
    }

    function Tstart(){
        // setInterval("if(!over)s.vMove();",500);
        $.Schedule(1.5,
            (function(){
                $.Msg("auto move");
                if(!over)s.vMove();
                Tstart();
            })
        );
    }

    function Trotate(){
        s.rotate();
    }

    function TvMove(){
        s.vMove();
    }

    function TlMove(){ 
        s.hMove(-1);
    }

    function TrMove(){
        s.hMove(1);
    }

    function Tfalldown(){
        s.falldown();
    }

    //Maybe no use
    (function () {
        GameEvents.Subscribe( "tetris_start", Tstart);
    })();

    (function() {
        Game.AddCommand( "+TrotateButton", Trotate, "", 0 );
        Game.AddCommand( "+MoveDownButton", TvMove, "", 0 );
        Game.AddCommand( "+MoveLeftButton", TlMove, "", 0 );
        Game.AddCommand( "+MoveRightButton", TrMove, "", 0 );
        Game.AddCommand( "+FasetDownButton", Tfalldown, "", 0);
    })();
