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

void
wl_surface_destroy_shim(struct wl_surface *wl_surface) {
  wl_surface_destroy(wl_surface);
}

void
wl_region_destroy_shim(struct wl_region *wl_region) {
  wl_region_destroy(wl_region);
}

void
wl_surface_set_opaque_region_shim(struct wl_surface *wl_surface, struct wl_region *wl_region) {
  wl_surface_set_opaque_region(wl_surface, wl_region);
}

void
wl_surface_set_input_region_shim(struct wl_surface *wl_surface, struct wl_region *wl_region) {
  wl_surface_set_input_region(wl_surface, wl_region);
}

struct wl_region *
wl_compositor_create_region_shim(struct wl_compositor *compositor) {
  return wl_compositor_create_region(compositor);
}

void
wl_region_add_shim(struct wl_region* wl_region, int x, int y, int width, int height)
{
    wl_region_add(wl_region, x, y, width, height);
}

void
wl_region_subtract_shim(struct wl_region* wl_region, int x, int y, int width, int height)
{
    wl_region_subtract(wl_region, x, y, width, height);
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

int wl_callback_add_listener_shim(struct wl_callback *wl_callback,
                         const struct wl_callback_listener *listener, void *data) {
  return wl_callback_add_listener(wl_callback,listener, data);
}

struct wl_callback *
wl_surface_frame_shim(struct wl_surface *wl_surface) {
  return wl_surface_frame(wl_surface);
}

struct wl_subsurface *
wl_subcompositor_get_subsurface_shim(struct wl_subcompositor *subcomp,
                                     struct wl_surface *target, struct wl_surface *parent) {
  return wl_subcompositor_get_subsurface(subcomp, target, parent);
}

void
wl_callback_destroy_shim(struct wl_callback *wl_callback) {
  wl_callback_destroy(wl_callback);
}

void
wl_surface_damage_buffer_shim(struct wl_surface *surface, int x1, int x2, int x3, int x4) {
  wl_surface_damage_buffer(surface, x1, x2, x3, x4);
}

void
wl_subsurface_set_sync_shim(struct wl_subsurface *sub) {
  wl_subsurface_set_sync(sub);
}

void
wl_subsurface_set_desync_shim(struct wl_subsurface *sub) {
  wl_subsurface_set_desync(sub);
}

void
wl_subsurface_destroy_shim(struct wl_subsurface *sub) {
  wl_subsurface_destroy(sub);
}

struct wl_pointer *
wl_seat_get_pointer_shim(struct wl_seat *seat) {
  return wl_seat_get_pointer(seat);
}

void
wl_pointer_add_listener_shim(struct wl_pointer *pointer, struct wl_pointer_listener *listener, void *data) {
  wl_pointer_add_listener(pointer, listener, data);
}

void
wl_seat_add_listener_shim(struct wl_seat *seat, struct wl_seat_listener *listener, void *data) {
  wl_seat_add_listener(seat, listener, data);
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
 
