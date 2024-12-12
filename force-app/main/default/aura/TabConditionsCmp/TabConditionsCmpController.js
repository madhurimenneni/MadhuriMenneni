({
    doInit: function(component) {
       
      var action=  component.get('c.getMdata');  
        action.setCallback(this,function(response)  
        {
        var state=response.getState();           
        if(state==='SUCCESS')
        {
           	 var custs = [];
                var conts = response.getReturnValue();
                for(var key in conts){
                    custs.push({value:conts[key], key:key});
                }
           
            component.set("v.childdata", conts);
            component.set("v.customers", custs);
         
        }
                         
                         
        });
  $A.enqueueAction(action);
    },
    handleActive: function(component,event) {
       var tab = event.getSource();
        var test= tab.get('v.id');
        var action = component.get('c.getCdata');
        action.setParams({"Names":test});
        action.setCallback(this,function(response){
            var state = response.getState();               
                if(state ==='SUCCESS'){   
                   var chlds = [];
                var chldsdata = response.getReturnValue();
                for(var key in chldsdata){
                    chlds.push({value:chldsdata[key], key:key});
                }
                 component.set("v.childConditions", chlds);   
                }
        });
         $A.enqueueAction(action);
    },
    handleChange: function(component, event) {
        var bb = event.getSource().get("v.checked"); 
        var bbc = event.getSource().get("v.value"); 
        console.log('bb'+bb);
        console.log('bbc'+bbc);
        var ChildRecs = component.get("v.displayMap");
		var newMap = {arg1: bbc, arg2:bb};
		Object.assign(ChildRecs, newMap);
   },
    saveClick: function(component, event) {
       var tab = component.get("v.displayMap");
        var action = component.get('c.updateCondition');
        action.setParams({"mdtIds":tab});
        action.setCallback(this,function(response){
            var state = response.getState();               
                if(state !=''){   
                 /*  var chlds = [];
                var chldsdata = response.getReturnValue();
                for(var key in chldsdata){
                    chlds.push({value:chldsdata[key], key:key});
                }
                 component.set("v.childConditions", chlds);   
                */
                    alert('Success');
                }
        });
         $A.enqueueAction(action);   }
    
})