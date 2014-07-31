from pyramid.config import Configurator


def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """
    config = Configurator(settings=settings)
    config.include('pyramid_chameleon')
    config.add_static_view('static', 'rta3web:static', cache_max_age=3600)
    config.add_route('socket_io', 'socket.io/*remaining')
    config.add_route('graph_update', '/graph_update')
    config.add_route('graph_channel', '/graph_channel')
    config.add_route('boss_update', '/boss_update')
    config.add_route('home', '/')
    config.add_static_view('deform/deform/static', 'deform:static')
    config.add_route('deform', '/deform')
    config.scan()
    return config.make_wsgi_app()
