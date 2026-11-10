use proc_macro::TokenStream;
use quote::quote;
use syn::{ItemEnum, ItemStruct};

pub fn component_impl(item: TokenStream) -> TokenStream {
  let component_name = if let Ok(component_struct) = syn::parse2::<ItemStruct>(item.clone().into())
  {
    component_struct.ident.clone()
  } else if let Ok(component_enum) = syn::parse2::<ItemEnum>(item.clone().into()) {
    component_enum.ident.clone()
  } else {
    return syn::Error::new(
      proc_macro2::Span::call_site(),
      "[ecs::component] can only be applied to a struct or enum",
    )
    .to_compile_error()
    .into();
  };

  let mut output = item;

  output.extend::<TokenStream>(
    quote! {
      impl ::ecs::EcsComponent for #component_name {}

      ::ecs::inventory::submit! {
        ::ecs::ComponentInventoryEntry {
          register: |storage: &mut ::ecs::EcsStorage| {
            storage.register_component::<#component_name>();
          },
        }
      }
    }
    .into(),
  );

  output
}
