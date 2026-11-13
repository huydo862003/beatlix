use proc_macro::TokenStream;
use quote::quote;
use syn::{Fields, ItemStruct};

pub fn archetype_impl(item: TokenStream) -> TokenStream {
  let Ok(archetype_struct) = syn::parse2::<ItemStruct>(item.into()) else {
    return syn::Error::new(
      proc_macro2::Span::call_site(),
      "[ecs::archetype] can only be applied to a struct",
    )
    .to_compile_error()
    .into();
  };

  let Fields::Named(ref named_fields) = archetype_struct.fields else {
    return syn::Error::new(
      archetype_struct.ident.span(),
      "[ecs::archetype] requires a struct with named fields",
    )
    .to_compile_error()
    .into();
  };

  let archetype_name = &archetype_struct.ident;

  let field_names: Vec<_> = named_fields
    .named
    .iter()
    .map(|field| field.ident.as_ref().unwrap())
    .collect();

  let field_types: Vec<_> = named_fields.named.iter().map(|field| &field.ty).collect();

  quote! {
    #archetype_struct

    impl ::ecs::EcsArchetype for #archetype_name {
      fn component_ids() -> Vec<::ecs::EcsComponentId> {
        vec![
          #( <#field_types as ::ecs::EcsComponent>::get_id(), )*
        ]
      }

      fn write_to_storage(
        self,
        storage: &mut ::ecs::EcsStorage,
        entity_id: ::ecs::EcsEntityId,
      ) {
        #(
          storage.set_entity_component_slot(entity_id, self.#field_names);
        )*
      }
    }

    #(
      impl ::ecs::EcsArchetypeWithComponent<#field_types> for #archetype_name {}
    )*

    ::ecs::inventory::submit! {
      ::ecs::ArchetypeInventoryEntry {
        register: |storage: &mut ::ecs::EcsStorage| {
          storage.register_archetype::<#archetype_name>();
        },
      }
    }
  }
  .into()
}
