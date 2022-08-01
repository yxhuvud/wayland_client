#include "wayland-client.h"
#include "./xdg-shell-client-protocol.h"

struct wl_registry *
wl_display_get_registry_shim(struct wl_display *wl_display) {
  return wl_display_get_registry(wl_display);
}

int
wl_registry_add_listener_shim(struct wl_registry *wl_registry,
                         const struct wl_registry_listener *listener, void *data) {
  return wl_registry_add_listener(wl_registry,listener, data);
}

void *
wl_registry_bind_shim(struct wl_registry *wl_registry, uint32_t name, const struct wl_interface *interface, uint32_t version) {
  return wl_registry_bind(wl_registry, name, interface, version);
}

struct wl_surface *
wl_compositor_create_surface_shim(struct wl_compositor *wl_compositor) {
  return wl_compositor_create_surface(wl_compositor);
}

struct wl_shm_pool *
wl_shm_create_pool_shim(struct wl_shm *shm, int fd, int size) {
  return wl_shm_create_pool(shm, fd, size);
}

void
wl_shm_pool_destroy_shim(struct wl_shm_pool *pool) {
  return wl_shm_pool_destroy(pool);
}

struct wl_buffer *
wl_shm_pool_create_buffer_shim(struct wl_shm_pool *pool, int offset, int width, int height, int stride, unsigned int format) {
  return wl_shm_pool_create_buffer( pool,  offset,  width, height, stride, format);
}

void
wl_buffer_destroy_shim(struct wl_buffer *buffer) {
  return wl_buffer_destroy(buffer);
}

int wl_buffer_add_listener_shim(struct wl_buffer *wl_buffer, const struct wl_buffer_listener *listener, void *data) {
  return wl_buffer_add_listener(wl_buffer, listener, data);
}

void
wl_surface_attach_shim(struct wl_surface *surface, struct wl_buffer *buffer, int x, int y) {
  wl_surface_attach(surface, buffer, x, y);
}

void
wl_surface_commit_shim(struct wl_surface *surface) {
  wl_surface_commit(surface);
}

void
wl_surface_damage_buffer_shim(struct wl_surface *surface, int x1, int x2, int x3, int x4) {
  wl_surface_damage_buffer(surface, x1, x2, x3, x4);
}

struct xdg_surface *
xdg_wm_base_get_xdg_surface_shim(struct xdg_wm_base *xdg_wm_base, struct wl_surface *surface)
{
  return xdg_wm_base_get_xdg_surface(xdg_wm_base, surface);
}

struct xdg_toplevel *
xdg_surface_get_toplevel_shim(struct xdg_surface *xdg_surface) {
  return xdg_surface_get_toplevel(xdg_surface);
}

void
xdg_toplevel_set_title_shim(struct xdg_toplevel *xdg_toplevel, const char *title) {
  xdg_toplevel_set_title(xdg_toplevel,  title);
}

int
xdg_wm_base_add_listener_shim(struct xdg_wm_base *xdg_wm_base,
                         const struct xdg_wm_base_listener *listener, void *data)
{
  return xdg_wm_base_add_listener(xdg_wm_base, listener, data);
}

void
xdg_wm_base_pong_shim(struct xdg_wm_base *xdg_wm_base, uint32_t serial)
{
        xdg_wm_base_pong(xdg_wm_base, serial);
}

int
xdg_surface_add_listener_shim(struct xdg_surface *xdg_surface,
                              const struct xdg_surface_listener *listener, void *data)
{
  return xdg_surface_add_listener(xdg_surface, listener, data);
}

int
xdg_toplevel_add_listener_shim(struct xdg_toplevel *xdg_toplevel,
                              const struct xdg_toplevel_listener *listener, void *data)
{
  return xdg_toplevel_add_listener(xdg_toplevel, listener, data);
}


void
xdg_surface_ack_configure_shim(struct xdg_surface *xdg_surface, uint32_t serial)
{
        xdg_surface_ack_configure(xdg_surface, serial);
}



/* int */
/* wl_display_add_listener_shim(struct wl_display *wl_display, */
/*                         const struct wl_display_listener *listener, void *data) { */
/*   return wl_display_add_listener(wl_display, listener, data); */
/* } */
