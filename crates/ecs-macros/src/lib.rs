mod ecs;

use proc_macro::TokenStream;

use crate::ecs::{archetype_impl, component_impl, world_impl};

#[proc_macro_attribute]
pub fn component(_attribute: TokenStream, item: TokenStream) -> TokenStream {
  component_impl(item)
}

#[proc_macro_attribute]
pub fn archetype(_attribute: TokenStream, item: TokenStream) -> TokenStream {
  archetype_impl(item)
}

#[proc_macro_attribute]
pub fn world(_attribute: TokenStream, item: TokenStream) -> TokenStream {
  world_impl(item)
}
