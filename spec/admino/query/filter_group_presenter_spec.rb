require 'spec_helper'

module Admino
  module Query
    describe FilterGroupPresenter do
      subject(:presenter) { FilterGroupPresenter.new(filter_group, view) }
      let(:view) { RailsViewContext.new }
      let(:filter_group) do
        double(
          'FilterGroup',
          query_i18n_key: :query_name,
          i18n_key: :filter_group,
          param_name: :filter_group
        )
      end
      let(:request_object) do
        double(
          'ActionDispatch::Request',
          query_parameters: { 'filter_group' => 'bar' },
          path: '/'
        )
      end

      before do
        view.stub(:request).and_return(request_object)
      end

      describe '#scope_link' do
        subject { presenter.scope_link(:foo) }

        before do
          filter_group.stub(:is_scope_active?).with(:foo).and_return(false)
        end

        context 'active CSS class' do
          before do
            filter_group.stub(:is_scope_active?).with(:foo).and_return(true)
          end

          it 'adds an is-active class' do
            should have_tag(:a, with: { class: 'is-active' })
          end

          context 'if an :active_class option is specified' do
            subject { presenter.scope_link(:foo, active_class: 'active') }

            it 'adds it' do
              should have_tag(:a, with: { class: 'active' })
            end
          end
        end

        context 'else' do
          it 'does not add it' do
            should_not have_tag(:a, with: { class: 'is-active' })
          end
        end

        context 'label' do
          before do
            presenter.stub(:scope_name).with(:foo).and_return('scope_name')
          end

          it 'uses #scope_name method' do
            should have_tag(:a, text: 'scope_name')
          end

          context 'if a second parameter is supplied' do
            subject { presenter.scope_link(:foo, 'test', active_class: 'active') }

            it 'uses it' do
              should have_tag(:a, text: 'test')
            end
          end
        end

        context 'URL' do
          before do
            presenter.stub(:scope_path).with(:foo).and_return('URL')
          end

          it 'uses #scope_path method' do
            should have_tag(:a, href: 'URL')
          end
        end
      end

      describe '#scope_params' do
        context 'if scope is nil' do
          it 'deletes the filter_group param' do
            expect(presenter.scope_params(nil)).not_to have_key 'filter_group'
          end
        end

        context 'else' do
          it 'deletes the filter_group param' do
            expect(presenter.scope_params(:bar)[:filter_group]).to eq 'bar'
          end
        end
      end

      describe '#name' do
        context do
          before do
            I18n.backend.store_translations(
              :en,
              query: { filter_groups: { query_name: { filter_group: { name: 'NAME' } } } }
            )
          end

          it 'returns a I18n translatable name for the filter_group' do
            expect(presenter.name).to eq 'NAME'
          end
        end

        context 'if no translation is available' do
          it 'falls back to a titleized version of the filter_group name' do
            expect(presenter.name).to eq 'Filter Group'
          end
        end
      end

      describe '#scope_name' do
        context do
          before do
            I18n.backend.store_translations(
              :en,
              query: { filter_groups: { query_name: { filter_group: { scopes: { bar: 'NAME' } } } } }
            )
          end

          it 'returns a I18n translatable name for the scope' do
            expect(presenter.scope_name(:bar)).to eq 'NAME'
          end
        end

        context 'if no translation is available' do
          it 'falls back to a titleized version of the scope name' do
            expect(presenter.scope_name(:bar)).to eq 'Bar'
          end
        end
      end
    end
  end
end

