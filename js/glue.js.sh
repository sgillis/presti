#! /bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo """
// Start Elm
presti = Elm.fullscreen(Elm.Presti, {
    'sliderValue': 50,
    'donePlaying': true,
    'modelSent': false,
    'submitError': false,
    'currentTime': new Date().getTime() / 1000,
    'setModel': {
        'startDate': 0,
        'now': 0,
        'screen': 'QuestionScreen',
        'username': '',
        'password': '',
        'submit': false,
        'submitE': false,
        'submitted': false,
        'subject': {
            'number': ''
        },
        'example': {
            'i': 0,
            'rates': [50],
            'samples': [1],
            'repeats': [0],
            'sound': {
                'playSound': true,
                'soundId': 1
            }
        },
        'practice': {
            'i': 0,
            'rates': [50],
            'samples': [1],
            'repeats': [0],
            'sound': {
                'playSound': true,
                'soundId': 1
            },
            'firstPhase': 1,
            'error': false,
            'endEarly': false,
            'done': false
        },
        'experiment': {
            'i': 0,
            'rates': [50],
            'samples': [1],
            'repeats': [0],
            'sound': {
                'playSound': true,
                'soundId': 1
            }
        },
        'instructions': {
            'slider': 50,
            'sound': {
                'playSound': true,
                'soundId': 1
            }
        },
        'questions': {
            'errors': {
                'geslacht': false,
                'leeftijd': false,
                'vraag1': false,
                'vraag2': false,
                'vraag3': false,
                'vraag4': false,
                'vraag5': false,
                'vraag6': false,
                'vraag7': false,
                'vraag8': false,
                'vraag9': false,
                'vraag10': false,
                'vraag11': false,
            },
            'geslacht': '',
            'leeftijd': '',
            'vraag1': '',
            'vraag2': '',
            'vraag3': '',
            'vraag4': '',
            'vraag5': '',
            'vraag6': '',
            'vraag7': '',
            'vraag8': '',
            'vraag9': '',
            'vraag10': '',
            'vraag11': '',
            'opmerking1': '',
            'opmerking2': '',
            'opmerking3': '',
            'opmerking4': '',
            'opmerking5': '',
            'opmerking6': '',
            'opmerking7': '',
            'opmerking8': '',
            'opmerking9': '',
            'opmerking10': '',
        }
    }
});

// Submit the current time every second
(function submitTime(){
    presti.ports.currentTime.send(new Date().getTime() / 1000);
    setTimeout(submitTime, 1000);
})();

// Functions to play sound
var sound = (function(){
    var id = 0;
    var register_sound = function(newId){
        id = newId;
    }
    var get_sound_element = function(){
        return document.getElementById(id);
    }
    var object = {
        register_sound: register_sound,
        get_sound_element: get_sound_element
    };
    return object;
})();

function play_sound(){
    var element = sound.get_sound_element();
    if (element != null) {
        element.play();
        presti.ports.donePlaying.send(true);
    }
}

function delay_play_sound(bool){
    // Dirty hack to make sure that we do not play the sound before the id is
    // updated
    if(bool){
        setTimeout(play_sound, 200);
    };
}

// Subscribe to playSound port
presti.ports.playSound.subscribe(delay_play_sound);

// Subscribe to soundId port
presti.ports.soundId.subscribe(sound.register_sound);

// Start foundation
function refresh_foundation(x){
    \$(document).foundation();
}

// Get slider value
function slider_value(){
    var val = int(document.getElementsByClassName(
        'range-slider')[0].getAttribute('data-slider'));
    presti.ports.sliderValue.send(val);
}

// Subscribe to refreshFoundation port
presti.ports.refreshFoundation.subscribe(refresh_foundation);

// Submit slider changes to Elm
\$(document).foundation({
    slider: {
        on_change: function(){
            presti.ports.sliderValue.send(
                parseInt(\$('#slider').attr('data-slider')));
        }
    }
});

// Model variable

var model = (function(){
    var elmModel = {};
    var justSent = false;
    var storedState = null;
    var justSaved = false;

    var create_ratings = function(rates, repeats, practice, sampleNames){
        return rates.map(function(val, index, rs){
            return {
                'position': index+1,
                'rating': val,
                'sample': sampleNames[index],
                'repeats': repeats[index],
                'practice': practice
            }
        });
    };

    var create_post_string = function(){
        m = {
            'subject': {
                'number': elmModel.subject.number,
                'experimenter': elmModel.username,
                'start_date': new Date(elmModel.startDate*1000).toISOString(),
                'end_date': new Date(elmModel.now*1000).toISOString()
            },
            'questions': {
                'question1': elmModel.questions.vraag1,
                'question2': elmModel.questions.vraag2,
                'question3': elmModel.questions.vraag3,
                'question4': elmModel.questions.vraag4,
                'question5': elmModel.questions.vraag5,
                'question6': elmModel.questions.vraag6,
                'question7': elmModel.questions.vraag7,
                'question8': elmModel.questions.vraag8,
                'question9': elmModel.questions.vraag9,
                'question10': elmModel.questions.vraag10,
                'question11': elmModel.questions.vraag11,
                'remark1': elmModel.questions.opmerking1,
                'remark2': elmModel.questions.opmerking2,
                'remark3': elmModel.questions.opmerking3,
                'remark4': elmModel.questions.opmerking4,
                'remark5': elmModel.questions.opmerking5,
                'remark6': elmModel.questions.opmerking6,
                'remark7': elmModel.questions.opmerking7,
                'remark8': elmModel.questions.opmerking8,
                'remark9': elmModel.questions.opmerking9,
                'remark10': elmModel.questions.opmerking10,
                'age': parseInt(elmModel.questions.leeftijd),
                'sex': elmModel.questions.geslacht
            },
            'authentication': {
                'username': elmModel.username,
                'password': elmModel.password
            },
            'ratings': create_ratings(
                elmModel.experiment.rates,elmModel.experiment.repeats,
                false, experimentSamples).concat(
                    create_ratings(
                        elmModel.practice.rates,elmModel.practice.repeats,
                        true, practiceSamples))
        }
        return JSON.stringify(m);
    };

    var update_model = function(new_model){
        elmModel = new_model;
        if(elmModel.submit == true && justSent == false){
            justSent = true
            x = new XMLHttpRequest();
            var url = '$BACKEND_URL';
            x.open('POST', url+'/experiment', true);
            x.setRequestHeader('Accept', 'application/json');
            x.onload = function(){
                console.log(this.responseText);
                if(this.responseText != '{\"success\":true}'){
                    presti.ports.submitError.send(true);
                };
                presti.ports.modelSent.send(true);
            }
            x.send(create_post_string())
            setTimeout(function(){ justSent = false; }, 2000);
        }

        if(elmModel.screen == 'SubjectScreen'){
            storedState = localStorage.getItem(
                'presti-'+elmModel.subject.number);
        } else if(elmModel.password == '' && justSaved == false) {
            console.log('Saving');
            localStorage.setItem('presti-'+elmModel.subject.number,
                JSON.stringify(elmModel));
            justSaved = true;
            setTimeout(function(){ justSaved = false; }, 5000);
        }

        if (elmModel.screen != 'SubjectScreen' && storedState != null) {
            console.log('Loading');
            m = JSON.parse(storedState)
            presti.ports.setModel.send(m);
            storedState = null;
        }
    };

    return {
        'update_model': update_model,
        'create_post_string': create_post_string,
        'get_elm_model': function(){ return elmModel; }
    };
})();

presti.ports.elmModel.subscribe(model.update_model);

var practiceSamples = ['sample1',
                       'sample2',
                       'sample3',
                       'sample4',
                       'sample5',
                       'sample6',
                       'sample7',
                       'sample8',
                       'sample9',
                       'sample10']

var experimentSamples =
    [ '1001_PRELEX_BOB010421(01).wav'
    , '1002_PRELEX_BOB010421(01).wav'
    , '1003_PRELEX_BOB010700(01).wav'
    , '1006_PRELEX_BOB010804(01).wav'
    , '1009_PRELEX_BOB011000(01).wav'
    , '1010_PRELEX_BOB011000(01).wav'
    , '1011_PRELEX_BOB011028(01).wav'
    , '1013_PRELEX_BOB020002(01).wav'
    , '1015_PRELEX_BRA000900(01).wav'
    , '1016_PRELEX_BRA000900(01).wav'
    , '1017_PRELEX_BRA000900(01).wav'
    , '1018_PRELEX_BRA000900(01).wav'
    , '1020_PRELEX_BRA000900(01).wav'
    , '1021_PRELEX_BRA000900(01).wav'
    , '1024_PRELEX_BRA000927(01).wav'
    , '1025_PRELEX_BRA000927(01).wav'
    , '1026_PRELEX_BRA000927(01).wav'
    , '1027_PRELEX_BRA001029(01).wav'
    , '1028_PRELEX_BRA001029(01).wav'
    , '1032_PRELEX_BRA010002(01).wav'
    , '1035_PRELEX_BRA010002(01).wav'
    , '1041_PRELEX_BRA010131(01).wav'
    , '1043_PRELEX_BRA010304(01).wav'
    , '1044_PRELEX_BRA010304(01).wav'
    , '1047_PRELEX_BRA010401(01).wav'
    , '1048_PRELEX_BRA010500(01).wav'
    , '1049_PRELEX_BRA010602(01).wav'
    , '1051_PRELEX_BRA010631(01).wav'
    , '1052_PRELEX_BRA010801(01).wav'
    , '1053_PRELEX_BRA010801(01).wav'
    , '1055_PRELEX_BRA010901(01).wav'
    , '1056_PRELEX_BRA010901(01).wav'
    , '1057_PRELEX_BRA010901(01).wav'
    , '1058_PRELEX_BRA010901(01).wav'
    , '1059_PRELEX_BRA010901(01).wav'
    , '1061_PRELEX_BRI000527(01).wav'
    , '1066_PRELEX_BRI000701(01).wav'
    , '1067_PRELEX_BRI000803(01).wav'
    , '1069_PRELEX_BRI000900(01).wav'
    , '1075_PRELEX_BRI000928(01).wav'
    , '1076_PRELEX_BRI000928(01).wav'
    , '1079_PRELEX_BRI000928(01).wav'
    , '1080_PRELEX_BRI000928(01).wav'
    , '1081_PRELEX_BRI000928(01).wav'
    , '1082_PRELEX_BRI000928(01).wav'
    , '1084_PRELEX_BRI000928(01).wav'
    , '1085_PRELEX_BRI000928(01).wav'
    , '1086_PRELEX_BRI000928(01).wav'
    , '1089_PRELEX_BRI000928(01).wav'
    , '1090_PRELEX_BRI000928(01).wav'
    , '1091_PRELEX_BRI001029(01).wav'
    , '1094_PRELEX_BRI001029(01).wav'
    , '1095_PRELEX_BRI001029(01).wav'
    , '1097_PRELEX_BRI001029(01).wav'
    , '1098_PRELEX_BRI001029(01).wav'
    , '1101_PRELEX_BRI001029(01).wav'
    , '1102_PRELEX_BRI001029(01).wav'
    , '1104_PRELEX_BRI010003(01).wav'
    , '1106_PRELEX_BRI010003(01).wav'
    , '1109_PRELEX_BRI010030(01).wav'
    , '1110_PRELEX_BRI010030(01).wav'
    , '1111_PRELEX_BRI010030(01).wav'
    , '1112_PRELEX_BRI010030(01).wav'
    , '1114_PRELEX_BRI010030(01).wav'
    , '1115_PRELEX_BRI010030(01).wav'
    , '1116_PRELEX_BRI010030(01).wav'
    , '1117_PRELEX_BRI010030(01).wav'
    , '1120_PRELEX_BRI010030(01).wav'
    , '1121_PRELEX_BRI010030(01).wav'
    , '1122_PRELEX_BRI010030(01).wav'
    , '1123_PRELEX_BRI010030(01).wav'
    , '1124_PRELEX_BRI010128(01).wav'
    , '1127_PRELEX_BRI010128(01).wav'
    , '1128_PRELEX_BRI010128(01).wav'
    , '1134_PRELEX_BRI010401(01).wav'
    , '1135_PRELEX_BRI010401(01).wav'
    , '1136_PRELEX_BRI010401(01).wav'
    , '1137_PRELEX_BRI010401(01).wav'
    , '1141_PRELEX_BRI010425(01).wav'
    , '1144_PRELEX_BRI010525(01).wav'
    , '1145_PRELEX_BRI010525(01).wav'
    , '1146_PRELEX_BRI010629(01).wav'
    , '1147_PRELEX_BRI010629(01).wav'
    , '1148_PRELEX_BRI010928(01).wav'
    , '1152_PRELEX_CHL000830(01).wav'
    , '1155_PRELEX_CHL001122(01).wav'
    , '1156_PRELEX_CHL001122(01).wav'
    , '1157_PRELEX_CHL001122(01).wav'
    , '1158_PRELEX_CHL001122(01).wav'
    , '1160_PRELEX_CHL010027(01).wav'
    , '1164_PRELEX_CHL010027(01).wav'
    , '1166_PRELEX_CHL010027(01).wav'
    , '1167_PRELEX_CHL010027(01).wav'
    , '1168_PRELEX_CHL010128(01).wav'
    , '1170_PRELEX_CHL010128(01).wav'
    , '1171_PRELEX_CHL010128(01).wav'
    , '1175_PRELEX_CHL010401(01).wav'
    , '1176_PRELEX_CHL010401(01).wav'
    , '1177_PRELEX_CHL010430(01).wav'
    , '1178_PRELEX_CHL010430(01).wav'
    , '1181_PRELEX_CHL010803(01).wav'
    , '1182_PRELEX_CHL010803(01).wav'
    , '1186_PRELEX_CHL010803(01).wav'
    , '1188_PRELEX_CHL010803(01).wav'
    , '1189_PRELEX_CHL010902(01).wav'
    , '1190_PRELEX_CHL010902(01).wav'
    , '1191_PRELEX_CHL010902(01).wav'
    , '1192_PRELEX_CHL010902(01).wav'
    , '1193_PRELEX_CHL010902(01).wav'
    , '1196_PRELEX_CHL011008(01).wav'
    , '1197_PRELEX_CHL011008(01).wav'
    , '1199_PRELEX_CHL011102(01).wav'
    , '1200_PRELEX_CHL011102(01).wav'
    , '1201_PRELEX_CLE000605(01).wav'
    , '1204_PRELEX_CLE000703(01).wav'
    , '1205_PRELEX_CLE000703(01).wav'
    , '1207_PRELEX_CLE000905(01).wav'
    , '1208_PRELEX_CLE000905(01).wav'
    , '1210_PRELEX_CLE000905(01).wav'
    , '1211_PRELEX_CLE000905(01).wav'
    , '1213_PRELEX_CLE000905(01).wav'
    , '1215_PRELEX_CLE000905(01).wav'
    , '1216_PRELEX_CLE000905(01).wav'
    , '1220_PRELEX_CLE000905(01).wav'
    , '1221_PRELEX_CLE000905(01).wav'
    , '1222_PRELEX_CLE001004(01).wav'
    , '1226_PRELEX_CLE001101(01).wav'
    , '1227_PRELEX_CLE001101(01).wav'
    , '1228_PRELEX_CLE001101(01).wav'
    , '1229_PRELEX_CLE001101(01).wav'
    , '1231_PRELEX_CLE001129(01).wav'
    , '1232_PRELEX_CLE001129(01).wav'
    , '1233_PRELEX_CLE001129(01).wav'
    , '1234_PRELEX_CLE001129(01).wav'
    , '1238_PRELEX_CLE001129(01).wav'
    , '1239_PRELEX_CLE001129(01).wav'
    , '1240_PRELEX_CLE001129(01).wav'
    , '1241_PRELEX_CLE010027(01).wav'
    , '1244_PRELEX_CLE010027(01).wav'
    , '1245_PRELEX_CLE010027(01).wav'
    , '1246_PRELEX_CLE010027(01).wav'
    , '1251_PRELEX_CLE010027(01).wav'
    , '1252_PRELEX_CLE010027(01).wav'
    , '1253_PRELEX_CLE010127(01).wav'
    , '1254_PRELEX_CLE010127(01).wav'
    , '1255_PRELEX_CLE010127(01).wav'
    , '1257_PRELEX_CLE010230(01).wav'
    , '1258_PRELEX_CLE010230(01).wav'
    , '1261_PRELEX_CLE010409(01).wav'
    , '1262_PRELEX_CLE010409(01).wav'
    , '1263_PRELEX_CLE010409(01).wav'
    , '1264_PRELEX_CLE010409(01).wav'
    , '1265_PRELEX_CLE010409(01).wav'
    , '1266_PRELEX_CLE010507(01).wav'
    , '1267_PRELEX_CLE010507(01).wav'
    , '1268_PRELEX_CLE010507(01).wav'
    , '1269_PRELEX_CLE010507(01).wav'
    , '1270_PRELEX_CLE010507(01).wav'
    , '1271_PRELEX_CLE010507(01).wav'
    , '1272_PRELEX_CLE010701(01).wav'
    , '1273_PRELEX_CLE010801(01).wav'
    , '1274_PRELEX_CLE010801(01).wav'
    , '1275_PRELEX_CLE010801(01).wav'
    , '1277_PRELEX_CLE011002(01).wav'
    , '1279_PRELEX_CLE011002(01).wav'
    , '1280_PRELEX_CLE011002(01).wav'
    , '1283_PRELEX_ELI000702(01).wav'
    , '1284_PRELEX_ELI000802(01).wav'
    , '1285_PRELEX_ELI000802(01).wav'
    , '1286_PRELEX_ELI000802(01).wav'
    , '1287_PRELEX_ELI000802(01).wav'
    , '1288_PRELEX_ELI000802(01).wav'
    , '1289_PRELEX_ELI000802(01).wav'
    , '1290_PRELEX_ELI000907(01).wav'
    , '1292_PRELEX_ELI001005(01).wav'
    , '1293_PRELEX_ELI001005(01).wav'
    , '1295_PRELEX_ELI001005(01).wav'
    , '1297_PRELEX_ELI001130(01).wav'
    , '1298_PRELEX_ELI001130(01).wav'
    , '1299_PRELEX_ELI010103(01).wav'
    , '1301_PRELEX_ELI010103(01).wav'
    , '1302_PRELEX_ELI010103(01).wav'
    , '1303_PRELEX_ELI010103(01).wav'
    , '1304_PRELEX_ELI010200(01).wav'
    , '1306_PRELEX_ELI010200(01).wav'
    , '1308_PRELEX_ELI010402(01).wav'
    , '1309_PRELEX_ELI010604(01).wav'
    , '1311_PRELEX_ELI010701(01).wav'
    , '1312_PRELEX_ELI010904(01).wav'
    , '1313_PRELEX_ELI011002(01).wav'
    , '1315_PRELEX_ELI011002(01).wav'
    , '1317_PRELEX_ELO001101(01).wav'
    , '1320_PRELEX_ELO001101(01).wav'
    , '1321_PRELEX_ELO010102(01).wav'
    , '1322_PRELEX_ELO010102(01).wav'
    , '1323_PRELEX_ELO010102(01).wav'
    , '1324_PRELEX_ELO010102(01).wav'
    , '1325_PRELEX_ELO010201(01).wav'
    , '1326_PRELEX_ELO010201(01).wav'
    , '1327_PRELEX_ELO010201(01).wav'
    , '1328_PRELEX_ELO010201(01).wav'
    , '1329_PRELEX_ELO010201(01).wav'
    , '1330_PRELEX_ELO010201(01).wav'
    , '1332_PRELEX_ELO010201(01).wav'
    , '1333_PRELEX_ELO010201(01).wav'
    , '1334_PRELEX_ELO010201(01).wav'
    , '1335_PRELEX_ELO010201(01).wav'
    , '1336_PRELEX_ELO010201(01).wav'
    , '1337_PRELEX_ELO010201(01).wav'
    , '1338_PRELEX_ELO010404(01).wav'
    , '1339_PRELEX_ELO010630(01).wav'
    , '1340_PRELEX_ELO010731(01).wav'
    , '1341_PRELEX_ELO010830(01).wav'
    , '1342_PRELEX_ELO010830(01).wav'
    , '1343_PRELEX_ELO010830(01).wav'
    , '1344_PRELEX_ELO010830(01).wav'
    , '1345_PRELEX_ELO011001(01).wav'
    , '1346_PRELEX_ELO011001(01).wav'
    , '1348_PRELEX_ELO011001(01).wav'
    , '1349_PRELEX_ELO011026(01).wav'
    , '1350_PRELEX_ELO011026(01).wav'
    , '1351_PRELEX_EVE000802(01).wav'
    , '1353_PRELEX_EVE000902(01).wav'
    , '1354_PRELEX_EVE001001(01).wav'
    , '1355_PRELEX_EVE001001(01).wav'
    , '1356_PRELEX_EVE001124(01).wav'
    , '1357_PRELEX_EVE001124(01).wav'
    , '1358_PRELEX_EVE001124(01).wav'
    , '1360_PRELEX_EVE001124(01).wav'
    , '1361_PRELEX_EVE001124(01).wav'
    , '1364_PRELEX_EVE010029(01).wav'
    , '1365_PRELEX_EVE010029(01).wav'
    , '1366_PRELEX_EVE010029(01).wav'
    , '1368_PRELEX_EVE010029(01).wav'
    , '1369_PRELEX_EVE010029(01).wav'
    , '1370_PRELEX_EVE010029(01).wav'
    , '1371_PRELEX_EVE010328(01).wav'
    , '1372_PRELEX_EVE010328(01).wav'
    , '1373_PRELEX_EVE010426(01).wav'
    , '1374_PRELEX_EVE010426(01).wav'
    , '1375_PRELEX_EVE010426(01).wav'
    , '1376_PRELEX_EVE010426(01).wav'
    , '1377_PRELEX_EVE010602(01).wav'
    , '1378_PRELEX_EVE010902(01).wav'
    , '1379_PRELEX_EVE010928(01).wav'
    , '1380_PRELEX_EVE010928(01).wav'
    , '1381_PRELEX_EVE010928(01).wav'
    , '2268_PRELEX_AMB010425(03).wav'
    , '2269_PRELEX_AMB010601(02).wav'
    , '2270_PRELEX_AMB010601(06).wav'
    , '2271_PRELEX_AMB010601(06).wav'
    , '2272_PRELEX_AMB010601(06).wav'
    , '2273_PRELEX_AMB010601(06).wav'
    , '2274_PRELEX_AMB010601(06).wav'
    , '2275_PRELEX_AMB010601(06).wav'
    , '2276_PRELEX_AMB010601(06).wav'
    , '2277_PRELEX_AMB010601(06).wav'
    , '2278_PRELEX_AMB010601(06).wav'
    , '2279_PRELEX_AMB010601(06).wav'
    , '2282_PRELEX_AMB010705(03).wav'
    , '2286_PRELEX_AMB011030(01).wav'
    , '2287_PRELEX_AMB011030(01).wav'
    , '2288_PRELEX_AMB011030(08).wav'
    , '2290_PRELEX_AMB011119(04).wav'
    , '2291_PRELEX_AMB020101(03).wav'
    , '2292_PRELEX_AMB020101(04).wav'
    , '2293_PRELEX_AMB020627(01).wav'
    , '2296_PRELEX_AMB020905(02).wav'
    , '2298_PRELEX_AMB020905(02).wav'
    , '2301_PRELEX_AMB020905(05).wav'
    , '2308_PRELEX_AMB020927(04).wav'
    , '2309_PRELEX_AMB020927(05).wav'
    , '2310_PRELEX_ANN010327(02).wav'
    , '2314_PRELEX_ANN010428(02).wav'
    , '2316_PRELEX_ANN010721(05).wav'
    , '2318_PRELEX_ANN010817(03).wav'
    , '2319_PRELEX_ANN010817(04).wav'
    , '2320_PRELEX_ANN010817(08).wav'
    , '2322_PRELEX_ANN010817(08).wav'
    , '2324_PRELEX_ANN010817(08).wav'
    , '2326_PRELEX_ANN010817(08).wav'
    , '2327_PRELEX_ANN010817(08).wav'
    , '2330_PRELEX_ANN011019(01).wav'
    , '2331_PRELEX_ANN011019(01).wav'
    , '2333_PRELEX_ANN011019(06).wav'
    , '2334_PRELEX_ANN011019(06).wav'
    , '2336_PRELEX_ANN011124(01).wav'
    , '2337_PRELEX_ANN011124(01).wav'
    , '2339_PRELEX_ANN011124(09).wav'
    , '2340_PRELEX_ANN020118(01).wav'
    , '2341_PRELEX_ANN020118(06).wav'
    , '2342_PRELEX_ANN020118(09).wav'
    , '2344_PRELEX_ANN020320(03).wav'
    , '2345_PRELEX_EMM010725(04).wav'
    , '2346_PRELEX_EMM010725(05).wav'
    , '2347_PRELEX_EMM010725(06).wav'
    , '2348_PRELEX_EMM010725(07).wav'
    , '2349_PRELEX_EMM010725(07).wav'
    , '2350_PRELEX_EMM010822(03).wav'
    , '2351_PRELEX_EMM010919(01).wav'
    , '2352_PRELEX_EMM011024(01).wav'
    , '2353_PRELEX_EMM011024(01).wav'
    , '2354_PRELEX_EMM011024(01).wav'
    , '2355_PRELEX_EMM011024(01).wav'
    , '2356_PRELEX_EMM011024(01).wav'
    , '2357_PRELEX_EMM011024(01).wav'
    , '2358_PRELEX_EMM011024(01).wav'
    , '2359_PRELEX_EMM011024(05).wav'
    , '2360_PRELEX_EMM011122(02).wav'
    , '2361_PRELEX_EMM011122(05).wav'
    , '2362_PRELEX_EMM011122(05).wav'
    , '2363_PRELEX_EMM011122(05).wav'
    , '2366_PRELEX_EMM020122(02).wav'
    , '2367_PRELEX_EMM020122(03).wav'
    , '2368_PRELEX_EMM020122(05).wav'
    , '2369_PRELEX_EMM020122(08).wav'
    , '2370_PRELEX_EMM020122(08).wav'
    , '2371_PRELEX_EMM020226(01).wav'
    , '2372_PRELEX_EMM020226(01).wav'
    , '2373_PRELEX_EMM020226(01).wav'
    , '2375_PRELEX_EMM020226(02).wav'
    , '2376_PRELEX_EMM020226(04).wav'
    , '2377_PRELEX_EMM020226(04).wav'
    , '2378_PRELEX_EMM020326(04).wav'
    , '2379_PRELEX_EMM020508(01).wav'
    , '2380_PRELEX_EMM020508(04).wav'
    , '2381_PRELEX_EMM020508(05).wav'
    , '2382_PRELEX_EMM020609(01).wav'
    , '2383_PRELEX_EMM020609(05).wav'
    , '2384_PRELEX_JOR011123(08).wav'
    , '2386_PRELEX_JOR020412(01).wav'
    , '2387_PRELEX_JOR020412(02).wav'
    , '2391_PRELEX_KLA010724(04).wav'
    , '2392_PRELEX_KLA010819(01).wav'
    , '2393_PRELEX_KLA010819(01).wav'
    , '2394_PRELEX_KLA010819(01).wav'
    , '2395_PRELEX_KLA010819(01).wav'
    , '2396_PRELEX_KLA010819(01).wav'
    , '2399_PRELEX_KLA010819(02).wav'
    , '2400_PRELEX_KLA010819(02).wav'
    , '2401_PRELEX_KLA010819(02).wav'
    , '2402_PRELEX_KLA010819(02).wav'
    , '2403_PRELEX_KLA010819(02).wav'
    , '2405_PRELEX_KLA010925(01).wav'
    , '2406_PRELEX_KLA010925(01).wav'
    , '2407_PRELEX_KLA010925(02).wav'
    , '2408_PRELEX_KLA010925(04).wav'
    , '2409_PRELEX_KLA011106(01).wav'
    , '2410_PRELEX_KLA011106(01).wav'
    , '2411_PRELEX_KLA020025(02).wav'
    , '2412_PRELEX_KLA020025(04).wav'
    , '2414_PRELEX_KLA020118(04).wav'
    , '2416_PRELEX_MIG010429(03).wav'
    , '2418_PRELEX_MIG010429(06).wav'
    , '2419_PRELEX_MIG010600(01).wav'
    , '2424_PRELEX_MIG010600(01).wav'
    , '2425_PRELEX_MIG010700(03).wav'
    , '2426_PRELEX_MIG010700(03).wav'
    , '2427_PRELEX_MIG010700(04).wav'
    , '2428_PRELEX_MIG010827(02).wav'
    , '2429_PRELEX_MIG010827(02).wav'
    , '2430_PRELEX_MIG010827(03).wav'
    , '2431_PRELEX_MIG010827(03).wav'
    , '2432_PRELEX_MIG010827(03).wav'
    , '2434_PRELEX_MIG010827(05).wav'
    , '2436_PRELEX_MIG010827(06).wav'
    , '2438_PRELEX_MIG010923(01).wav'
    , '2439_PRELEX_MIG010923(01).wav'
    , '2449_PRELEX_ROB011015(01).wav'
    , '2450_PRELEX_ROB011015(02).wav'
    , '2452_PRELEX_ROB011015(06).wav'
    , '2453_PRELEX_ROX000801(03).wav'
    , '2454_PRELEX_ROX000801(03).wav'
    , '2455_PRELEX_ROX000801(06).wav'
    , '2459_PRELEX_ROX001102(05).wav'
    , '2460_PRELEX_ROX010003(02).wav'
    , '2461_PRELEX_ROX010201(01).wav'
    , '2464_PRELEX_ROX010201(05).wav'
    , '2467_PRELEX_ROX010311(03).wav'
    , '2468_PRELEX_ROX010311(03).wav'
    , '2473_PRELEX_ROX010311(06).wav'
    , '2477_PRELEX_ROX010513(09).wav'
    , '2478_PRELEX_ROX010605(05).wav'
    , '2479_PRELEX_ROX010710(01).wav'
    , '2480_PRELEX_ROX010710(01).wav'
    , '2482_PRELEX_ROX010710(08).wav'
    , '2483_PRELEX_ROX010807(02).wav'
    , '2484_PRELEX_ROX010807(02).wav'
    , '2485_PRELEX_ROX010807(04).wav'
    , '2486_PRELEX_ROX010807(04).wav'
    , '2487_PRELEX_ROX020108(05).wav'
    , '2488_PRELEX_ROX020215(03).wav'
    , '2489_PRELEX_ROX020215(04).wav'
    , '2490_PRELEX_ROX020416(01).wav'
    , '2491_PRELEX_TES020027(03).wav'
    , '2495_PRELEX_TES020208(02).wav'
    , '2496_PRELEX_TES020208(02).wav'
    , '2497_PRELEX_TES020208(06).wav'
    , '2498_PRELEX_TES020208(06).wav'
    , '2502_PRELEX_TES020507(01).wav'
    , '2503_PRELEX_TES020507(01).wav'
    , '2504_PRELEX_TES020507(02).wav'
    , '2507_PRELEX_YAR010124(04).wav'
    , '2508_PRELEX_YAR010124(04).wav'
    , '2509_PRELEX_YAR010124(04).wav'
    , '2510_PRELEX_YAR010124(08).wav'
    , '2512_PRELEX_YAR010124(09).wav'
    , '2514_PRELEX_YAR010124(10).wav'
    , '2516_PRELEX_YAR010222(03).wav'
    , '2520_PRELEX_YAR010417(07).wav'
    , '2521_PRELEX_YAR010521(01).wav'
    , '2523_PRELEX_YAR010521(09).wav'
    , '2525_PRELEX_YAR010521(13).wav'
    , '2526_PRELEX_YAR010521(13).wav'
    , '2527_PRELEX_YAR010521(13).wav'
    , '850_PRELEX_ATT000603(01).wav'
    , '852_PRELEX_ATT000603(02).wav'
    , '853_PRELEX_ATT000603(02).wav'
    , '857_PRELEX_ATT000804(01).wav'
    , '860_PRELEX_ATT000909(01).wav'
    , '861_PRELEX_ATT000909(01).wav'
    , '862_PRELEX_ATT000909(01).wav'
    , '864_PRELEX_ATT000909(01).wav'
    , '865_PRELEX_ATT000909(01).wav'
    , '866_PRELEX_ATT001014(01).wav'
    , '867_PRELEX_ATT001014(01).wav'
    , '869_PRELEX_ATT001014(01).wav'
    , '870_PRELEX_ATT001014(01).wav'
    , '871_PRELEX_ATT001014(01).wav'
    , '872_PRELEX_ATT001014(01).wav'
    , '873_PRELEX_ATT001014(01).wav'
    , '874_PRELEX_ATT001014(01).wav'
    , '875_PRELEX_ATT001014(01).wav'
    , '876_PRELEX_ATT001014(01).wav'
    , '877_PRELEX_ATT001014(01).wav'
    , '878_PRELEX_ATT001014(01).wav'
    , '879_PRELEX_ATT001014(01).wav'
    , '880_PRELEX_ATT001014(01).wav'
    , '881_PRELEX_ATT001014(01).wav'
    , '882_PRELEX_ATT001014(01).wav'
    , '883_PRELEX_ATT001014(01).wav'
    , '884_PRELEX_ATT001014(01).wav'
    , '885_PRELEX_ATT001014(01).wav'
    , '886_PRELEX_ATT001014(01).wav'
    , '887_PRELEX_ATT001014(01).wav'
    , '888_PRELEX_ATT001014(01).wav'
    , '889_PRELEX_ATT001014(01).wav'
    , '890_PRELEX_ATT001014(01).wav'
    , '891_PRELEX_ATT001014(01).wav'
    , '892_PRELEX_ATT001014(01).wav'
    , '893_PRELEX_ATT001014(01).wav'
    , '895_PRELEX_ATT001014(01).wav'
    , '896_PRELEX_ATT001014(01).wav'
    , '897_PRELEX_ATT001014(01).wav'
    , '898_PRELEX_ATT001014(01).wav'
    , '899_PRELEX_ATT001014(01).wav'
    , '900_PRELEX_ATT001014(01).wav'
    , '901_PRELEX_ATT001014(01).wav'
    , '902_PRELEX_ATT001014(01).wav'
    , '903_PRELEX_ATT001014(01).wav'
    , '904_PRELEX_ATT001014(01).wav'
    , '905_PRELEX_ATT001014(01).wav'
    , '906_PRELEX_ATT001014(01).wav'
    , '907_PRELEX_ATT001014(01).wav'
    , '908_PRELEX_ATT001014(01).wav'
    , '909_PRELEX_ATT001014(01).wav'
    , '910_PRELEX_ATT001014(01).wav'
    , '911_PRELEX_ATT001014(01).wav'
    , '913_PRELEX_ATT001106(01).wav'
    , '916_PRELEX_ATT001106(01).wav'
    , '917_PRELEX_ATT001106(01).wav'
    , '918_PRELEX_ATT001106(01).wav'
    , '919_PRELEX_ATT001106(01).wav'
    , '921_PRELEX_ATT010010(01).wav'
    , '922_PRELEX_ATT010010(01).wav'
    , '925_PRELEX_ATT010010(01).wav'
    , '926_PRELEX_ATT010010(01).wav'
    , '927_PRELEX_ATT010010(01).wav'
    , '928_PRELEX_ATT010010(01).wav'
    , '930_PRELEX_ATT010010(01).wav'
    , '931_PRELEX_ATT010010(01).wav'
    , '935_PRELEX_ATT010010(01).wav'
    , '936_PRELEX_ATT010118(01).wav'
    , '937_PRELEX_ATT010118(01).wav'
    , '939_PRELEX_ATT010209(01).wav'
    , '941_PRELEX_ATT010209(01).wav'
    , '942_PRELEX_ATT010209(01).wav'
    , '947_PRELEX_ATT010310(01).wav'
    , '949_PRELEX_ATT010310(01).wav'
    , '950_PRELEX_ATT010310(01).wav'
    , '951_PRELEX_ATT010405(01).wav'
    , '952_PRELEX_ATT010600(01).wav'
    , '953_PRELEX_ATT010600(01).wav'
    , '954_PRELEX_ATT010600(01).wav'
    , '956_PRELEX_ATT010600(01).wav'
    , '957_PRELEX_ATT010600(01).wav'
    , '958_PRELEX_ATT010600(01).wav'
    , '959_PRELEX_ATT010700(01).wav'
    , '961_PRELEX_ATT010700(01).wav'
    , '962_PRELEX_ATT010700(01).wav'
    , '963_PRELEX_ATT010700(01).wav'
    , '964_PRELEX_ATT010700(01).wav'
    , '965_PRELEX_ATT010700(01).wav'
    , '966_PRELEX_ATT010700(01).wav'
    , '967_PRELEX_ATT010700(01).wav'
    , '968_PRELEX_ATT010700(01).wav'
    , '969_PRELEX_ATT010700(01).wav'
    , '971_PRELEX_ATT020001(01).wav'
    , '972_PRELEX_ATT020001(01).wav'
    , '973_PRELEX_BOB010003(01).wav'
    , '974_PRELEX_BOB010003(01).wav'
    , '976_PRELEX_BOB010003(01).wav'
    , '978_PRELEX_BOB010107(01).wav'
    , '979_PRELEX_BOB010107(01).wav'
    , '981_PRELEX_BOB010107(01).wav'
    , '983_PRELEX_BOB010107(01).wav'
    , '985_PRELEX_BOB010107(01).wav'
    , '986_PRELEX_BOB010107(01).wav'
    , '989_PRELEX_BOB010205(01).wav'
    , '990_PRELEX_BOB010205(01).wav'
    , '992_PRELEX_BOB010205(01).wav'
    , '993_PRELEX_BOB010405(01).wav'
    , '994_PRELEX_BOB010405(01).wav'
    , '995_PRELEX_BOB010405(01).wav'
    , '997_PRELEX_BOB010405(01).wav'
    , '998_PRELEX_BOB010405(01).wav'
    , '999_PRELEX_BOB010421(01).wav'
    ]
""" > $DIR"/glue.js"
