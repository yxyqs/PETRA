function [error, msj, res] = run_components (action, args)
error = 0;
msj = '';

if strcmp (action, 'train')
    
    %Parametros del metodo:
    
    prompt = {'Components'' size','Components'' distance'};
    dlg_title = 'Please enter method''s parameters';
    num_lines = 1;
    def = {'10','10'};
    
    % esto se debería pedir por pantalla
    method.name='relevancia';
    method.th = 0.7;
    
    
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    if isempty(answer)
        error = 1;
        msj = 'Procedure cancelled by user';
        res = [];
        return;
    end
    comp_size = str2double(answer{1});
    jump = str2double(answer{2});    
    clasif = 'svm'; % answer{3};  % Clasificador
    
    % esto se debería pedir por pantalla
    pclasif = '';    % Parametros del clasificador
    
    if isnan ( comp_size) || comp_size<1, error = 1; msj = 'Components'' size should be greater than 1'; return; end
    if isnan ( jump )|| comp_size<1, error = 1; msj = 'Components'' distance should be greater than 1'; return; end
    
    
    % Extrae caracteristicas
    args_met = args ;
    args_met.jump = jump;
    args_met.comp_size = comp_size;
    args_met.feats = [];
    args_met.options = [];
    
    [error, msj, feats] = components (args_met);
    if error==1, return, end
    
    msg= 'Computing components'' accuracy';
    h = waitbar(0,msg);
    
    % Entrenamiento del clasificador
    S=size(args.imgs);
    nfolds=S(1);
    
    for i=1:feats.NVoxels;
        tr_data=args.imgs(:,feats.z(i):feats.z(i)+comp_size,feats.y(i):feats.y(i)+comp_size, feats.x(i):feats.x(i)+comp_size);
        cp=classperf(args.labels>0);
        indices = crossvalind('Kfold',size(args.imgs,1),nfolds);
        
        waitbar(i/feats.NVoxels)
        for p=1:nfolds
            
            test = (indices == p); train = ~test;
            train_data=tr_data(train,:);
            test_data=tr_data(test,:);
            tr_labels=args.labels(train);
            trnstruct.trn = feval (clasif, 'train', train_data, tr_labels>0, '', pclasif);
            trnstruct.labels=tr_labels>0;
            class= feval (clasif, 'classify', test_data, '', trnstruct, pclasif);
            classperf(cp, class.accuracy,test,'Positive', 1, 'Negative', 0);
        end
        res.values(i).cp.CorrectRate=cp.CorrectRate;
        
        res.values(i).cp.ErrorDistribution=cp.ErrorDistribution;
        res.rclasif(i).trn=trnstruct.trn;
        res.rclasif(i).labels=trnstruct.labels;
    end
    close(h)
    
    res.values(1).cp.GroundTruth=cp.GroundTruth;
    res.clasif = clasif;
    res.pclasif = pclasif;
    res.labels =  args.labels;
    res.jump = jump;
    res.comp_size = comp_size;
    res.feats = feats;
    res.method = method;
    
    clas =[];
    pmap=calcular_mprec(res,feats,S);
    [~,featv]=agregado_d_votos(clas,res);
    
    res.pmap=pmap;
    res.featv=featv';
    
    
elseif strcmp(action, 'classify')
    
    %Si se aplic� m�scara o se redujo la dimension de las imagenes,
    %aqu� tambi�n debe hacerse
    
    % Extrae caracteristicas
    
    [error, msj, feats] = components (args.train);
    if error==1, return, end
    
    % Clasifica
    msg='Classifying components';
    h = waitbar(0,msg);
    
    S=size(args.imgs);
    NVoxels=feats.NVoxels;
    classes(1:NVoxels)=0;
    for i=1:NVoxels;
        tr_data=args.imgs(:,feats.z(i):feats.z(i)+args.train.comp_size,feats.y(i):feats.y(i)+args.train.comp_size, feats.x(i):feats.x(i)+args.train.comp_size);
        
        waitbar(i/NVoxels)
        resultclas = feval (args.train.clasif, 'classify', tr_data(:,:), '', args.train.rclasif(i), args.train.pclasif);
        classes(i) =resultclas.accuracy;
        
        
    end
    close(h)
    
    
    [class,featv]=agregado_d_votos(classes',args.train);
    
    % Muestra el resultado de la clasificacion
    for j=1:NVoxels
        res.values(j).cp.CorrectRate=classes(j);
    end
    res.comp_size=args.train.comp_size;
    pmap2=calcular_mprec(res,feats,S);
    args.train.options(2,:,:,:)=pmap2;
    args.train.options(1,:,:,:)=args.train.pmap;
    
    
    args.train=rmfield(args.train,'feats');
    args.train.feats=args.train.featv;
    
    %Define el colormap de la suma de votos
    cmap=colormap([0 0 0.600000023841858;0.00063661829335615 0.00229182606562972 0.619085848331451;0.0012732365867123 0.00458365213125944 0.638171672821045;0.00190985493827611 0.00687547819688916 0.657257497310638;0.0025464731734246 0.00916730426251888 0.676343262195587;0.00318309152498841 0.0114591298624873 0.695429086685181;0.00381970987655222 0.0137509563937783 0.714514911174774;0.00445632822811604 0.0160427819937468 0.733600735664368;0.0050929463468492 0.0183346085250378 0.752686560153961;0.00572956493124366 0.0206264331936836 0.771772384643555;0.00636618304997683 0.0229182597249746 0.790858209133148;0.00700280163437128 0.0252100862562656 0.809943974018097;0.00763941975310445 0.0275019127875566 0.82902979850769;0.00827603787183762 0.0297937374562025 0.848115622997284;0.00891265645623207 0.0320855639874935 0.867201447486877;0.0636957883834839 0.0842939242720604 0.826619148254395;0.118478916585445 0.136502280831337 0.786036849021912;0.173262044787407 0.188710644841194 0.745454549789429;0.228045165538788 0.240919008851051 0.704872250556946;0.28282830119133 0.293127357959747 0.664290010929108;0.337611436843872 0.345335721969604 0.623707711696625;0.392394542694092 0.397544085979462 0.583125412464142;0.447177678346634 0.449752449989319 0.542543113231659;0.501960813999176 0.501960813999176 0.501960813999176;0.518718242645264 0.532607138156891 0.532607138156891;0.535475671291351 0.563253462314606 0.563253462314606;0.552233159542084 0.593899786472321 0.593899786472321;0.568990588188171 0.624546110630035 0.624546110630035;0.585748016834259 0.655192494392395 0.655192494392395;0.602505445480347 0.68583881855011 0.68583881855011;0.619262933731079 0.716485142707825 0.716485142707825;0.636020362377167 0.74713146686554 0.74713146686554;0.652777791023254 0.777777791023254 0.777777791023254;0.688946783542633 0.80092591047287 0.80092591047287;0.725115776062012 0.82407408952713 0.82407408952713;0.761284708976746 0.847222208976746 0.847222208976746;0.797453701496124 0.870370388031006 0.870370388031006;0.833622694015503 0.893518507480621 0.893518507480621;0.869791686534882 0.916666686534882 0.916666686534882;0.905960619449615 0.939814805984497 0.939814805984497;0.942129611968994 0.962962985038757 0.962962985038757;0.978298604488373 0.986111104488373 0.986111104488373;0.980142533779144 0.90232390165329 0.90232390165329;0.981986403465271 0.818536639213562 0.818536639213562;0.983830332756042 0.734749436378479 0.734749436378479;0.985674262046814 0.650962233543396 0.650962233543396;0.987518131732941 0.567175030708313 0.567175030708313;0.989362061023712 0.483387798070908 0.483387798070908;0.991205990314484 0.399600565433502 0.399600565433502;0.99304986000061 0.315813362598419 0.315813362598419;0.994893789291382 0.232026144862175 0.232026144862175;0.975399076938629 0.222631618380547 0.201429292559624;0.955904364585876 0.213237091898918 0.170832440257072;0.936409652233124 0.20384256541729 0.140235587954521;0.916914880275726 0.194448038935661 0.109638728201389;0.897420167922974 0.185053512454033 0.079041875898838;0.877925455570221 0.175658985972404 0.0484450198709965;0.858430743217468 0.166264459490776 0.0178481657058001;0.8565354347229 0.16535110771656 0.0148734711110592;0.854640126228333 0.164437741041183 0.0118987774476409;0.852744817733765 0.163524389266968 0.00892408285290003;0.850849449634552 0.162611037492752 0.00594938872382045;0.848954141139984 0.161697670817375 0.00297469436191022;0.847058832645416 0.160784319043159 0]);
    
    
    %Guarda el resultado
    res.args = args;
    res.args.colormap=cmap;
    res.feats=featv';
    res.class=class;
    res.strix1='Precision Map';
    res.strix2='Votes Map';
    res.figFunction = 'representar_results2';
    res.comps = 1:size(res.feats,2);
    
end
end

function [class,feats]=agregado_d_votos(classes,res)

if isempty(classes)
    for i=1:res.feats.NVoxels
        classes(i,:)=xor(res.values(1).cp.GroundTruth-1,res.values(i).cp.ErrorDistribution);
    end
end
okopts={'relevancia','MAP'};
cl = find(strncmpi(res.method.name, okopts,numel(res.method.name)));
Th=res.method.th;

switch cl
    
    case 1 
        cont1(1:size(classes,2))=0;
        ErrD1(1:res.feats.NVoxels,1:size(classes,2))=0;
        
        for l=1:size(classes,2)
            for j=1:res.feats.NVoxels
                if res.values(j).cp.CorrectRate>Th
                    ErrD1(j,l)=ErrD1(j,l)+classes(j,l);
                    cont1(l)=cont1(l)+1;
                end
                
            end
        end
        feats1=sum(ErrD1)./cont1;
        class1=(feats1>0.5);
        
        cont2(1:size(classes,2))=0;
        ErrD2(1:res.feats.NVoxels,1:size(classes,2))=0;
        for l=1:size(classes,2)
            for j=1:res.feats.NVoxels
                ErrD2(j,l)=ErrD2(j,l)+classes(j,l);
                cont2(l)=cont2(l)+1;
            end
        end
        feats2=sum(ErrD2)./cont2;
        class2=(feats2>0.5);
        feats = [feats1; feats2];
        class=((class1+class2)/2)>0.5;
    case 2
        
        %         if nargin>2, labels=varargin{2}; end
        %         j=1;
        %         cont=1;
        %         ErrD=[];
        %         for cir3=1:jump:Z
        %             for cir2=1:jump:Y
        %                 for cir1=1:jump:X
        %                     if ~isfield(resultados(j).val(cir3,cir2,cir1),'cp'),
        %                         continueprobabilitc1(1:numel(grut),cont)=probac1;
        %                     elseif isempty(resultados(j).val(cir3,cir2,cir1).cp),
        %                         continue
        %                     elseif (resultados(j).val(cir3,cir2,cir1).cp.CorrectRate)==0,
        %                         continue
        %                     end
        %                     if cont==1, grut=(resultados(j).values(cir3,cir2,cir1).cp.GroundTruth);  prev=(resultados(j).val(cir3,cir2,cir1).cp.Prevalence); end
        %                     ErrDis=resultados(j).values(cir3,cir2,cir1).cp.ErrorDistribution;
        %                     testlabels=labels(resultados.testset);
        %                     assign=testlabels+ErrDis';
        %                     assign(assign==2)=0; probac1(1:numel(grut))=0;probac2(1:numel(grut))=0;%probac3(1:numel(grut))=0;probac4(1:numel(grut))=0;
        %                     apriorip=resultados.val(cir3,cir2,cir1).cp.DiagnosticTable./sum(resultados.val(cir3,cir2,cir1).cp.DiagnosticTable(:));
        %                     probac1(assign==0)=apriorip(1,1);
        %                     probac2(assign==1)=apriorip(2,2);
        %                     probac2(assign==0)=apriorip(1,2);
        %                     probac1(assign==1)=apriorip(2,1);
        %                     probabilitc1(1:numel(grut),cont)=probac1';
        %                     probabilitc2(1:numel(grut),cont)=probac2';
        %                     %probabilitc3(1:numel(grut),cont)=probac3';
        %                     %probabilitc4(1:numel(grut),cont)=probac4';
        %                     cont=cont+1;
        %                 end
        %             end
        %         end
        %         probabilitc1(probabilitc1==0)=eps;
        %         probabilitc2(probabilitc2==0)=eps;
        %         cp(j)=classperf(grut);
        %         opt1=sum(log(probabilitc1),2);
        %         opt2=sum(log(probabilitc2),2);
        %         [a,b]=sort([prev*opt1 (1-prev)*opt2],2);
        %         prec(j)=classperf(cp(j),b(:,2),'positive',2,'negative',1);
end

end


function [map]=calcular_mprec(res,feats,S)
msg= 'Building precision map';
h = waitbar(0,msg);
values=res.values;
z=feats.z ; y=feats.y ; x=feats.x;
comp_size=res.comp_size;
NVoxels= feats.NVoxels;
Z=S(2);Y=S(3);X=S(4);
map_fuz=zeros(Z,Y,X);fprintf .

counter=zeros(Z,Y,X);fprintf .

for l=1:NVoxels
    waitbar(l/NVoxels)
    tr_Acc=zeros(Z,Y,X);
    tr_Acc(z(l):z(l)+comp_size,y(l):y(l)+comp_size, x(l):x(l)+comp_size)=1;
    tr_Acc_pr=tr_Acc*(values(l).cp.CorrectRate);
    map_fuz=map_fuz+tr_Acc_pr;
    cont=tr_Acc;
    counter=counter+cont;
    
end
close(h)
map=map_fuz./counter;
map(isnan(map))=0;

end