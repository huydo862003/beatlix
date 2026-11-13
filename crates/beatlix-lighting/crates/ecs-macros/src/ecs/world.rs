use proc_macro::TokenStream;
use quote::quote;
use syn::{Fields, ItemStruct};

pub fn world_impl(item: TokenStream) -> TokenStream {
  let Ok(world_struct) = syn::parse2::<ItemStruct>(item.into()) else {
    return syn::Error::new(
      proc_macro2::Span::call_site(),
      "[ecs::world] can only be applied to a struct",
    )
    .to_compile_error()
    .into();
  };

  let Fields::Named(ref named_fields) = world_struct.fields else {
    return syn::Error::new(
      world_struct.ident.span(),
      "[ecs::world] requires a struct with named fields",
    )
    .to_compile_error()
    .into();
  };

  let has_storage_field = named_fields.named.iter().any(|field| {
    field.ident.as_ref().is_some_and(|ident| ident == "storage")
      && matches!(&field.ty, syn::Type::Path(type_path)
        if type_path.path.segments.last().is_some_and(|seg| seg.ident == "EcsStorage"))
  });

  if !has_storage_field {
    return syn::Error::new(
      world_struct.ident.span(),
      "[ecs::world] requires a field `storage: EcsStorage`",
    )
    .to_compile_error()
    .into();
  }

  let world_name = &world_struct.ident;

  quote! {
    #world_struct

    impl ::ecs::EcsWorld for #world_name {
      fn storage(&self) -> &::ecs::EcsStorage {
        &self.storage
      }

      fn storage_mut(&mut self) -> &mut ::ecs::EcsStorage {
        &mut self.storage
      }
    }
  }
  .into()
}
