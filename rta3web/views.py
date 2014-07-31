from pyramid.view import view_config
from pyramid.response import Response

#--------------------------File IO-------------------------------------------------------------------------
from webob import Request, Response
import os
class FileApp(object):

    def __init__(self, filename):
        self.filename = filename

    def __call__(self, environ, start_response):
        res = make_response(self.filename)
        return res(environ, start_response)

    
    def get_mimetype(filename):
        type, encoding = mimetypes.guess_type(filename)
         # We'll ignore encoding, even though we shouldn't really
        return type or 'application/octet-stream'

    def make_response(filename):
        import mimetypes
        print "filename"
        print filename.filename
        f = open(filename.filename, 'rb')
        type, encoding = mimetypes.guess_type(filename.filename)
        content_disposition_filename = f.name.encode('ascii', 'replace').split('/')
        content_disposition_filename = content_disposition_filename[-1]
        res = Response(content_type=type or 'application/octet-stream',
                        content_disposition='attachment; filename="%s"'
                        %content_disposition_filename.replace('"','\\')
                    )
        res.body = f.read()
        f.close()
        return res

#----------------------------------------------------------------------------------------------------------



#----------------------------SOCKET-IO and GEVENT------------------------------------------

from gevent import monkey; monkey.patch_all()
import gevent

from socketio.namespace import BaseNamespace
from socketio import socketio_manage
from socketio.mixins import BroadcastMixin

"""Basic broadcast Mixin, data is send to all connections using this Mixin"""
class TestMixin(BroadcastMixin):
    def __init__(self, *args, **kwargs):
        super(TestMixin, self).__init__(*args, **kwargs)
        if 'data' not in self.session:
            self.session['data'] = ""

    def setData(self, data):
        self.sessions['data'] = data

    def sendData(self, event, args, room):
        """This is sent to all (in this particular Namespace)"""
        pkt = dict(type="event",
                   name=event,
                   args=args,
                   endpoint=self.ns_name)
        #room_name = self._get_room_name(room)
        for sessid, socket in self.socket.server.sockets.iteritems():
            #if not hasattr(socket, 'rooms'):
                #continue
            #if room_name in socket.rooms:
                socket.send_packet(pkt)

"""Socket to transmit data to the linechart in soft real time"""
class GraphNamespace(BaseNamespace, TestMixin):

    def initialize(self):
        print "initialise!!!!!!!!!!!!!!!!!!!!00000!!!!!!!!!!!!!!!"
        

    def on_new_data(self, data):
        self.broadcast_event('data', data)

    def recv_connect(self):
        print ("recieved graph connection")
        def sendcpu():
            self.db = current_spectra.current_spectra()
            while True:
                spectrum, timestamp = self.db.getCurrentSpectrum()
                # spectrum = cnf.Base64Decode(spectrum)
                spectime = time.localtime(timestamp)
                timeS = '%02i:%02i:%02i on %02i/%02i/%04i'%(spectime[3], spectime[4], spectime[5], spectime[2], spectime[1], spectime[0])
                miny = spectrum.min()
                maxy = spectrum.max()
                freqs = cnf.getFreqs(1)/ 10e6
                data = np.empty((spectrum.size + freqs.size,), dtype=spectrum.dtype)
                data[0::2] = freqs
                data[1::2] = spectrum
                self.emit('data',{'data':json.dumps(data.tolist()),\
                                'maxx':freqs.max(),\
                                'minx':freqs.min(),\
                                'maxy':maxy,\
                                'miny':miny,\
                                'heading':"Spectrum taken at %s"%timeS,\
                                'xaxis':"Frequency (Mhz)",\
                                'yaxis':"Power (dBuV/m)"})
                print ("sent data for %s"%timeS)
                gevent.sleep(0.5)
        print"spawn updater"
        self.updater = gevent.Greenlet(sendcpu)
        self.updater.start()

    def recv_disconnect(self):
        self.updater.kill()
        self.db.close()
        self.broadcast_event('user_disconnect')
        self.disconnect(silent=True)

    def on_join(self, channel):
        self.join(channel)

"""Socket to transmit data to the bosschart in soft real time"""
class BossNamespace(BaseNamespace, TestMixin):

    def initialize(self):
        print "initialise!!!!!!!!!!!!!!!!!!!!00000!!!!!!!!!!!!!!!"
        

    def on_new_data(self, data):
        self.broadcast_event('data', data)

    def recv_connect(self):
        print ("recieved boss connection")
        def sendcpu():
            self.db = current_spectra.current_spectra(mode = 'r')
            while True:
                spectrum, timestamp = self.db.getCurrentSpectrum()
                # start = time.time()
                spectrum = spectrum[cnf.modes[1]['low_chan']:cnf.modes[1]['high_chan']]
                spectime = time.localtime(timestamp)
                # spectrum = np.random.rand(100) * 50 + 500
                # spectrum = np.arange(101)
                timeS = '%02i:%02i:%02i on %02i/%02i/%04i'%(spectime[3], spectime[4], spectime[5], spectime[2], spectime[1], spectime[0])
                
                # freqs = cnf.getFreqs(1)/ 10e6
                miny = np.asscalar(spectrum.min())
                maxy = np.asscalar(spectrum.max())
                js = json.dumps(spectrum.tolist())

                self.emit('data',{'spectrum':js,\
                                'maxy':maxy,\
                                'miny':miny,\
                                'heading':"Spectrum taken at %s"%timeS,\
                                'xaxis':"Frequency (Mhz)",\
                                'yaxis':"Power (dBuV/m)"})
                print ("sent data for %s"%timeS)
                gevent.sleep(0.01)
        print"spawn updater"
        self.updater = gevent.Greenlet(sendcpu)
        self.updater.start()

    def recv_disconnect(self):
        print "DISCONNECT"
        self.updater.kill()
        self.db.close()
        self.broadcast_event('user_disconnect')
        self.disconnect(silent=True)

    def on_join(self, channel):
        self.join(channel)

@view_config(route_name="socket_io")
def socketio_service(request):
    ret = socketio_manage(request.environ,
                    {'/chart': GraphNamespace,
                    '/boss' : BossNamespace},
                    request=request)

    return Response(ret)


#-------------------------------------------------------------------------------------------

#----------------------------FORMS with DEFORM----------------------------------------------
import colander
import deform.widget
from colander import Range
import datetime

from pyramid.httpexceptions import HTTPFound
from pyramid.view import view_config


@colander.deferred
def deferred_date_validator(node, kw):
    max_date = kw.get('max_date')
    if max_date is None:
        max_date = datetime.datetime.now()
    min_date = kw.get('min_date')
    if min_date is None:
        min_date=datetime.min
    return colander.Range(min=min_date, max=max_date)

class channel_date_range(colander.MappingSchema):
    date_time_start = colander.SchemaNode(colander.DateTime(default_tzinfo=None),
                    validator = deferred_date_validator,
                    widget=deform.widget.DateTimeInputWidget())
    date_time_end = colander.SchemaNode(colander.DateTime(default_tzinfo=None),
                    validator = deferred_date_validator,
                    widget=deform.widget.DateTimeInputWidget())

    Frequency = colander.SchemaNode(
                colander.String(),
                validator=colander.Length(max=10),
                widget=deform.widget.TextInputWidget(size=10),
                description='Frequency MHz')

#-------------------------------------------------------------------------------------------

#----------------------------VIEWS----------------------------------------------------------

from rfDB2 import current_spectra
from rfDB2 import monitor_conf as cnf
from rfDB2 import dbControl
import time
import numpy as np
import json

@view_config(route_name='home', renderer='templates/mytemplate.pt')
def my_view(request):
    return {'project': 'rta3web'}

@view_config(route_name='graph_update', renderer='templates/linechart_update.pt')
def graph_update_view(request):
    db = current_spectra.current_spectra()
    spectrum, timestamp = db.getCurrentSpectrum()
    spectime = time.localtime(timestamp)
    spectrum = cnf.Base64Decode(spectrum)
    timeS = '%02i:%02i:%02i on %02i/%02i/%04i'%(spectime[3], spectime[4], spectime[5], spectime[2], spectime[1], spectime[0])
    miny = spectrum.min()
    maxy = spectrum.max()
    freqs = cnf.getFreqs(1)/ 10e6
    data = np.empty((spectrum.size + freqs.size,), dtype=spectrum.dtype)
    data[0::2] = freqs
    data[1::2] = spectrum
    db.close()

    return {'data':json.dumps(data.tolist()),\
    'maxx':freqs.max(),\
    'minx':freqs.min(),\
    'maxy':maxy,\
    'miny':miny,\
    'heading':"Spectrum taken at %s"%timeS,\
    'xaxis':"Frequency (Mhz)",\
    'yaxis':"Power (dBuV/m)"}

@view_config(route_name='boss_update', renderer='templates/bosschart_update.pt')
def graph_update_view(request):
    db = current_spectra.current_spectra(mode = 'r')
    spectrum, timestamp = db.getCurrentSpectrum()
    spectime = time.localtime(timestamp)
    spectrum = spectrum[cnf.modes[1]['low_chan']:cnf.modes[1]['high_chan']]
    timeS = '%02i:%02i:%02i on %02i/%02i/%04i'%(spectime[3], spectime[4], spectime[5], spectime[2], spectime[1], spectime[0])
    freqs = cnf.getFreqs(1)[cnf.modes[1]['low_chan']:cnf.modes[1]['high_chan']] / 10e5
    db.close()

    miny = np.asscalar(spectrum.min())
    maxy = np.asscalar(spectrum.max())
    js = json.dumps(spectrum.tolist())

    return {'spectrum':js,\
    'freqs':json.dumps(freqs.tolist()),\
    'maxx':freqs.max(),\
    'minx':freqs.min(),\
    'maxy':maxy,\
    'miny':miny,\
    'heading':"Spectrum taken at %s"%timeS,\
    'xaxis':"Frequency (Mhz)",\
    'yaxis':"Power (dBuV/m)"}

@view_config(route_name='graph_channel', renderer='templates/linechart_channel.pt')
def graph_channel_view(request):
    import datetime
    
    db = dbControl.dbControl(cnf.monitor_db[0], cnf.monitor_db[1], cnf.monitor_db[2], cnf.monitor_db[3])

    mini = db.rfi_monitor_get_oldest_timestamp()
    minDateTime = datetime.datetime.fromtimestamp(mini+60)

    schema = channel_date_range().bind(min_date=minDateTime)
    form = deform.Form(schema,buttons=('submit','download'))
    reqts = form.get_widget_resources()

    for i in range(len(reqts['css'])):
        reqts['css'][i] = "deform:static/%s"%reqts['css'][i]
    for i in range(len(reqts['js'])):
        reqts['js'][i] = "deform:static/%s"%reqts['js'][i]

    sTimestamp = 0
    frequency = -1
    overranges = []
    times = []
    data = []


    if 'submit' in request.params:
        print "IN SUBMIT"
        controls = request.POST.items()
        print "controls"
        print controls
        try:
            appstruct = form.validate(controls)

            sTime = appstruct['date_time_start'].timetuple()
            eTime = appstruct['date_time_end'].timetuple()
            frequencyS = appstruct['Frequency']
            try:
                frequency = float(frequencyS)
            except ValueError:
                try:
                    floats = [float(s) for s in frequencyS.split(" ") if s.isDigit()]
                    frequency = floats[0]
                except:
                    print "Not valid input"


            channel = cnf.freq_to_chan(cnf.modes[0]['base_freq'],frequency,cnf.modes[0]['n_chan'], cnf.modes[0]['bandwidth'])
            # db.frequency_to_channel(frequency)

            print "frequency = %f channel = %i"%(frequency, channel)

            sTimestamp = int(time.mktime(sTime))
            eTimestamp = int(time.mktime(eTime))

            timeS = '%02i:%02i:%02i on %02i/%02i/%04i to %02i:%02i:%02i on %02i/%02i/%04i'%(sTime[3], sTime[4], sTime[5], sTime[2], sTime[1], sTime[0], eTime[3], eTime[4], eTime[5], eTime[2], eTime[1], eTime[0],)

            spectrum = db.rfi_monitor_get_range(sTimestamp, eTimestamp, 0, channel = channel) #362

            overranges = db.rfi_monitor_get_adc_overrange_pos(sTimestamp, eTimestamp)

            miny = spectrum.min()
            maxy = spectrum.max()


            times = np.arange(int(sTimestamp),int(sTimestamp + spectrum.size),1)

        except deform.ValidationFailure as e:
            return {'data':json.dumps([]),\
                    'times':"whhops",\
                    'heading':"",\
                    'form':e.render(),\
                    'reqts':reqts,\
                    'xaxis':"",\
                    'yaxis':"",\
                    'minx':0,\
                    'maxx':1,\
                    'miny':0,\
                    'maxy':1}

    elif 'download' in request.params:
        print "IN DOWNLOAD"
        controls = request.POST.items()
        try:
            appstruct = form.validate(controls)

            sTime = appstruct['date_time_start'].timetuple()
            eTime = appstruct['date_time_end'].timetuple()

            sTimestamp = int(time.mktime(sTime))
            eTimestamp = int(time.mktime(eTime))

            frequencyS = appstruct['Frequency']
            try:
                frequency = float(frequencyS)
            except ValueError:
                try:
                    floats = [float(s) for s in frequencyS.split(" ") if s.isDigit()]
                    frequency = floats[0]
                except:
                    print "Not valid input"


            channel = cnf.freq_to_chan(cnf.modes[0]['base_freq'],frequency,cnf.modes[0]['n_chan'], cnf.modes[0]['bandwidth'])

            timeS = '%02i_%02i_%02i_on_%02i_%02i_%04i_to_%02i_%02i_%02i_on_%02i_%02i_%04i'%(sTime[3], sTime[4], sTime[5], sTime[2], sTime[1], sTime[0], eTime[3], eTime[4], eTime[5], eTime[2], eTime[1], eTime[0],)

            spectrum = db.rfi_monitor_get_range(sTimestamp, eTimestamp, 0, channel = channel)



            indices = range(spectrum.shape[0])
            datetimes = [time.localtime(sTimestamp + i)[1:7] for i in indices]
            data = [[datetimes[i][0], datetimes[i][1], datetimes[i][2], datetimes[i][3], datetimes[i][4], datetimes[i][5], spectrum[i]] for i in indices]
            fileName = "%s/srv/%s.csv"%(cnf.root_dir,timeS)

            import os

            if not os.path.exists("%s/srv/"%cnf.root_dir):
                os.makedirs("%s/srv/"%cnf.root_dir)

            dbControl.array_to_csv_file(data,("month","day","hour","minute","second","day of week", "power dbuV/m"),fileName)
            fApp = FileApp(fileName)

            return fApp.make_response()

        except deform.ValidationFailure as e:
            return {'overrange':json.dumps(adc_overrange),\
                    'overrangeS':overrangeS,\
                    'times':"whoops",\
                    'form':e.render(),\
                    'reqts':reqts,
                    'xaxis':"",\
                    'yaxis':"",\
                    'minx':0,\
                    'maxx':1,\
                    'miny':0,\
                    'maxy':1}
    else:
        print "NO SUBMIT"
        sTimestamp = time.time() - 3600 * 2
        eTimestamp = time.time()
        #eTimestamp = eTimestamp - eTimestamp % 3600
        sTime = time.localtime(sTimestamp)
        eTime = time.localtime(eTimestamp)
        spectrum = db.rfi_monitor_get_range(sTimestamp, eTimestamp, 0, channel = 372)
        overranges = db.rfi_monitor_get_adc_overrange_pos(sTimestamp, eTimestamp)
        frequency = 70.4
        timeS = '%02i:%02i:%02i to %02i:%02i:%02i'%(sTime[3], sTime[4], sTime[5], eTime[3], eTime[4], eTime[5])
        miny = spectrum[:-2].min()
        maxy = spectrum[:-2].max()
        print np.where(spectrum==maxy)
        times = np.arange(int(sTimestamp),int(sTimestamp + spectrum.size),1)

        print len(overranges)
    
    db.close()

    return {'data':json.dumps(spectrum.tolist()),\
    'times':json.dumps(times.tolist()),\
    'overranges':json.dumps(overranges),\
    'maxx':int(sTimestamp + spectrum.size),\
    'minx':int(sTimestamp),\
    'maxy':maxy,\
    'miny':miny,\
    'heading':"%.2fMHz taken from %s"%(frequency,timeS),\
    'xaxis':"Time",\
    'yaxis':"Power (dBuV/m)",\
    'form':form.render(),\
    'reqts':reqts}

#-------------------------------------------------------------------------------------------